import XCTest
@testable import SaveTrack

final class Phase2IntegrationTests: XCTestCase {
    var dataManager: DataManager!
    
    override func setUp() {
        super.setUp()
        dataManager = DataManager.shared
        clearAllData()
    }
    
    override func tearDown() {
        clearAllData()
        super.tearDown()
    }
    
    private func clearAllData() {
        for entry in dataManager.entries {
            dataManager.deleteEntry(entry)
        }
        for goal in dataManager.goals {
            dataManager.deleteGoal(goal)
        }
    }
    
    // MARK: - Edit Entry Tests
    
    func testEditEntry() {
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
    
    // MARK: - Goal Celebration Tests
    
    func testGoalAchievementTriggersCelebration() {
        // Given
        let goal = Goal(name: "Test Goal", targetAmount: 100.0, period: .monthly)
        dataManager.saveGoal(goal)
        
        let category = Category.defaultCategories.first!
        
        // When - Add entries to complete goal
        let entry1 = Entry(amount: 50.0, categoryId: category.id)
        let entry2 = Entry(amount: 50.0, categoryId: category.id)
        dataManager.saveEntry(entry1)
        dataManager.saveEntry(entry2)
        
        // Then
        let updatedGoal = dataManager.goals.first!
        XCTAssertTrue(updatedGoal.isCompleted)
        XCTAssertNotNil(updatedGoal.completedAt)
    }
    
    // MARK: - Badge Tests
    
    func testBadgeEarning() {
        // Given
        let category = Category.defaultCategories.first!
        let calendar = Calendar.current
        
        // Create entries for 7 consecutive days
        var entries: [Entry] = []
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                entries.append(Entry(amount: 10.0, categoryId: category.id, timestamp: date))
                dataManager.saveEntry(entries.last!)
            }
        }
        
        // When
        var streak = Streak()
        streak.updateWithEntries(dataManager.entries)
        
        // Then
        XCTAssertTrue(streak.milestoneBadges.contains(7))
        XCTAssertNotNil(streak.badgeEarnedDates[7])
    }
    
    func testMultipleBadgesEarned() {
        // Given
        let category = Category.defaultCategories.first!
        let calendar = Calendar.current
        
        // Create entries for 30 consecutive days
        for dayOffset in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let entry = Entry(amount: 10.0, categoryId: category.id, timestamp: date)
                dataManager.saveEntry(entry)
            }
        }
        
        // When
        var streak = Streak()
        streak.updateWithEntries(dataManager.entries)
        
        // Then
        XCTAssertTrue(streak.milestoneBadges.contains(7))
        XCTAssertTrue(streak.milestoneBadges.contains(30))
        XCTAssertNotNil(streak.badgeEarnedDates[7])
        XCTAssertNotNil(streak.badgeEarnedDates[30])
    }
    
    // MARK: - Longest Streak Tests
    
    func testLongestStreakTracking() {
        // Given
        let category = Category.defaultCategories.first!
        let calendar = Calendar.current
        
        // Create entries with a gap, then a new streak
        for dayOffset in [5, 4, 3, 2, 1, 0] {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let entry = Entry(amount: 10.0, categoryId: category.id, timestamp: date)
                dataManager.saveEntry(entry)
            }
        }
        
        // When
        var streak = Streak()
        streak.updateWithEntries(dataManager.entries)
        
        // Then
        XCTAssertEqual(streak.longestStreak, 6)
        XCTAssertNotNil(streak.longestStreakStartDate)
        XCTAssertNotNil(streak.longestStreakEndDate)
    }
    
    // MARK: - Category Management Tests
    
    func testCustomCategoryCreation() {
        // Given
        let customCategory = Category(
            name: "Custom Test",
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
        XCTAssertEqual(found!.name, "Custom Test")
    }
    
    func testCustomCategoryDeletion() {
        // Given
        let customCategory = Category(
            name: "To Delete",
            emoji: "🗑️",
            isCustom: true,
            isDefault: false
        )
        dataManager.insertCategory(customCategory)
        
        XCTAssertTrue(dataManager.categories.contains { $0.id == customCategory.id })
        
        // When
        dataManager.deleteCategory(customCategory)
        
        // Then
        XCTAssertFalse(dataManager.categories.contains { $0.id == customCategory.id })
    }
    
    func testCannotDeleteDefaultCategory() {
        // Given
        let defaultCategory = Category.defaultCategories.first!
        
        // When
        dataManager.deleteCategory(defaultCategory)
        
        // Then - Should still exist
        let categories = dataManager.categories
        XCTAssertTrue(categories.contains { $0.id == defaultCategory.id })
    }
    
    // MARK: - Charts ViewModel Tests
    
    func testChartsViewModelDataPreparation() {
        // Given
        let category = Category.defaultCategories.first!
        let calendar = Calendar.current
        
        // Create entries over the last week
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let entry = Entry(amount: Decimal(dayOffset + 1) * 10, categoryId: category.id, timestamp: date)
                dataManager.saveEntry(entry)
            }
        }
        
        // When
        let viewModel = ChartsViewModel()
        viewModel.selectedPeriod = .week
        viewModel.updateData()
        
        // Then
        XCTAssertGreaterThan(viewModel.chartData.count, 0)
        XCTAssertGreaterThan(viewModel.totalSaved, 0)
        XCTAssertGreaterThan(viewModel.totalEntries, 0)
    }
    
    func testChartsViewModelCategoryBreakdown() {
        // Given
        let category1 = Category.defaultCategories[0]
        let category2 = Category.defaultCategories[1]
        
        let entry1 = Entry(amount: 30.0, categoryId: category1.id)
        let entry2 = Entry(amount: 20.0, categoryId: category2.id)
        let entry3 = Entry(amount: 10.0, categoryId: category1.id)
        
        dataManager.saveEntry(entry1)
        dataManager.saveEntry(entry2)
        dataManager.saveEntry(entry3)
        
        // When
        let viewModel = ChartsViewModel()
        viewModel.updateData()
        
        // Then
        XCTAssertGreaterThan(viewModel.categoryData.count, 0)
        let category1Data = viewModel.categoryData.first { $0.categoryId == category1.id }
        XCTAssertNotNil(category1Data)
    }
    
    // MARK: - Notification Manager Tests
    
    func testNotificationManagerSingleton() {
        let instance1 = NotificationManager.shared
        let instance2 = NotificationManager.shared
        
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - EntryViewModel Edit Tests
    
    func testEntryViewModelUpdate() {
        // Given
        let category = Category.defaultCategories.first!
        let entry = Entry(amount: 10.0, categoryId: category.id, note: "Original")
        dataManager.saveEntry(entry)
        
        let viewModel = EntryViewModel()
        
        // When
        viewModel.updateEntry(entry, amount: 25.0, categoryId: category.id, note: "Updated", photo: nil)
        
        // Then
        let updatedEntry = dataManager.entries.first!
        XCTAssertEqual(updatedEntry.amount, 25.0)
        XCTAssertEqual(updatedEntry.note, "Updated")
    }
}
