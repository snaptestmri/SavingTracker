import XCTest
@testable import SaveTrack

final class EntryViewModelTests: XCTestCase {
    var viewModel: EntryViewModel!
    var dataManager: DataManager!
    
    override func setUp() {
        super.setUp()
        dataManager = DataManager.shared
        viewModel = EntryViewModel()
        
        // Clear existing data
        for entry in dataManager.entries {
            dataManager.deleteEntry(entry)
        }
    }
    
    override func tearDown() {
        for entry in dataManager.entries {
            dataManager.deleteEntry(entry)
        }
        super.tearDown()
    }
    
    func testSaveEntry() {
        // Given
        let category = Category.defaultCategories.first!
        let amount: Decimal = 25.50
        let note = "Test note"
        
        // When
        viewModel.saveEntry(amount: amount, categoryId: category.id, note: note, photo: nil)
        
        // Then
        XCTAssertEqual(dataManager.entries.count, 1)
        let savedEntry = dataManager.entries.first!
        XCTAssertEqual(savedEntry.amount, amount)
        XCTAssertEqual(savedEntry.categoryId, category.id)
        XCTAssertEqual(savedEntry.note, note)
    }
    
    func testLastUsedCategoryTracking() {
        // Given
        let category1 = Category.defaultCategories[0]
        let category2 = Category.defaultCategories[1]
        
        // When - Save entry with category1
        viewModel.saveEntry(amount: 10.0, categoryId: category1.id, note: nil, photo: nil)
        
        // Then
        XCTAssertEqual(viewModel.lastUsedCategoryId, category1.id)
        
        // When - Save entry with category2
        viewModel.saveEntry(amount: 20.0, categoryId: category2.id, note: nil, photo: nil)
        
        // Then
        XCTAssertEqual(viewModel.lastUsedCategoryId, category2.id)
    }
    
    func testUpdateEntry() {
        // Given
        let category = Category.defaultCategories.first!
        let entry = Entry(amount: 10.0, categoryId: category.id, note: "Original")
        dataManager.saveEntry(entry)
        
        // When
        viewModel.updateEntry(entry, amount: 20.0, categoryId: category.id, note: "Updated", photo: nil)
        
        // Then
        XCTAssertEqual(dataManager.entries.count, 1)
        let updatedEntry = dataManager.entries.first!
        XCTAssertEqual(updatedEntry.amount, 20.0)
        XCTAssertEqual(updatedEntry.note, "Updated")
    }
    
    func testDeleteEntry() {
        // Given
        let category = Category.defaultCategories.first!
        let entry = Entry(amount: 10.0, categoryId: category.id)
        dataManager.saveEntry(entry)
        
        XCTAssertEqual(dataManager.entries.count, 1)
        
        // When
        viewModel.deleteEntry(entry)
        
        // Then
        XCTAssertEqual(dataManager.entries.count, 0)
    }
}
