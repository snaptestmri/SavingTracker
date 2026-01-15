import XCTest
@testable import SaveTrack

final class DataManagerTests: XCTestCase {
    var dataManager: DataManager!
    
    override func setUp() {
        super.setUp()
        dataManager = DataManager.shared
        
        // Clear existing data
        for entry in dataManager.entries {
            dataManager.deleteEntry(entry)
        }
        for goal in dataManager.goals {
            dataManager.deleteGoal(goal)
        }
    }
    
    override func tearDown() {
        for entry in dataManager.entries {
            dataManager.deleteEntry(entry)
        }
        for goal in dataManager.goals {
            dataManager.deleteGoal(goal)
        }
        super.tearDown()
    }
    
    func testDataManagerSingleton() {
        let instance1 = DataManager.shared
        let instance2 = DataManager.shared
        
        XCTAssertTrue(instance1 === instance2)
    }
    
    func testDefaultCategoriesInitialized() {
        let categories = dataManager.categories
        
        XCTAssertGreaterThanOrEqual(categories.count, Category.defaultCategories.count)
        
        for defaultCategory in Category.defaultCategories {
            let exists = categories.contains { $0.id == defaultCategory.id }
            XCTAssertTrue(exists, "Default category \(defaultCategory.name) should exist")
        }
    }
    
    func testEntryPersistence() {
        // Given
        let category = Category.defaultCategories.first!
        let entry = Entry(amount: 25.50, categoryId: category.id, note: "Test")
        
        // When
        dataManager.saveEntry(entry)
        
        // Then
        XCTAssertEqual(dataManager.entries.count, 1)
        let savedEntry = dataManager.entries.first!
        XCTAssertEqual(savedEntry.amount, entry.amount)
        XCTAssertEqual(savedEntry.categoryId, entry.categoryId)
        XCTAssertEqual(savedEntry.note, entry.note)
    }
    
    func testGoalPersistence() {
        // Given
        let goal = Goal(name: "Test Goal", targetAmount: 1000.0, period: .monthly)
        
        // When
        dataManager.saveGoal(goal)
        
        // Then
        XCTAssertEqual(dataManager.goals.count, 1)
        let savedGoal = dataManager.goals.first!
        XCTAssertEqual(savedGoal.name, goal.name)
        XCTAssertEqual(savedGoal.targetAmount, goal.targetAmount)
    }
    
    func testEntryUpdate() {
        // Given
        let category = Category.defaultCategories.first!
        let entry = Entry(amount: 10.0, categoryId: category.id, note: "Original")
        dataManager.saveEntry(entry)
        
        // When
        var updatedEntry = entry
        updatedEntry.amount = 20.0
        updatedEntry.note = "Updated"
        dataManager.updateEntry(updatedEntry)
        
        // Then
        XCTAssertEqual(dataManager.entries.count, 1)
        let savedEntry = dataManager.entries.first!
        XCTAssertEqual(savedEntry.amount, 20.0)
        XCTAssertEqual(savedEntry.note, "Updated")
    }
    
    func testGoalAutoUpdateOnEntry() {
        // Given
        let goal = Goal(name: "Test Goal", targetAmount: 100.0, period: .monthly)
        dataManager.saveGoal(goal)
        
        let category = Category.defaultCategories.first!
        let entry1 = Entry(amount: 30.0, categoryId: category.id)
        let entry2 = Entry(amount: 40.0, categoryId: category.id)
        let entry3 = Entry(amount: 30.0, categoryId: category.id)
        
        // When
        dataManager.saveEntry(entry1)
        dataManager.saveEntry(entry2)
        dataManager.saveEntry(entry3)
        
        // Then
        let updatedGoal = dataManager.goals.first!
        XCTAssertEqual(updatedGoal.currentAmount, 100.0)
        XCTAssertTrue(updatedGoal.isCompleted)
    }
    
    func testCustomCategoryCreation() {
        // Given
        let customCategory = Category(
            name: "Custom",
            emoji: "⭐",
            isCustom: true,
            isDefault: false
        )
        
        // When
        dataManager.insertCategory(customCategory)
        
        // Then
        let categories = dataManager.categories
        let found = categories.first { $0.id == customCategory.id }
        XCTAssertNotNil(found)
        XCTAssertTrue(found!.isCustom)
    }
    
    func testExportDataStructure() {
        // Given
        let category = Category.defaultCategories.first!
        let entry = Entry(amount: 10.0, categoryId: category.id)
        let goal = Goal(name: "Test", targetAmount: 100.0, period: .monthly)
        
        dataManager.saveEntry(entry)
        dataManager.saveGoal(goal)
        
        // When
        guard let exportData = dataManager.exportData() else {
            XCTFail("Export data should not be nil")
            return
        }
        
        // Then
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let decoded = try? decoder.decode(ExportData.self, from: exportData) else {
            XCTFail("Should be able to decode export data")
            return
        }
        
        XCTAssertEqual(decoded.entries.count, 1)
        XCTAssertEqual(decoded.goals.count, 1)
        XCTAssertNotNil(decoded.exportDate)
    }
    
    func testImportDataRestoresEntries() {
        // Given - Create and export data
        let category = Category.defaultCategories.first!
        let entry1 = Entry(amount: 10.0, categoryId: category.id, note: "Entry 1")
        let entry2 = Entry(amount: 20.0, categoryId: category.id, note: "Entry 2")
        
        dataManager.saveEntry(entry1)
        dataManager.saveEntry(entry2)
        
        guard let exportData = dataManager.exportData() else {
            XCTFail("Export data should not be nil")
            return
        }
        
        // Clear data
        dataManager.deleteEntry(entry1)
        dataManager.deleteEntry(entry2)
        XCTAssertEqual(dataManager.entries.count, 0)
        
        // When
        let success = dataManager.importData(exportData)
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(dataManager.entries.count, 2)
    }
}
