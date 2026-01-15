import XCTest
@testable import SaveTrack

final class SaveTrackIntegrationTests: XCTestCase {
    var dataManager: DataManager!
    
    override func setUp() {
        super.setUp()
        // Use a test database
        dataManager = DataManager.shared
        // Clear existing data for clean tests
        clearAllData()
    }
    
    override func tearDown() {
        clearAllData()
        super.tearDown()
    }
    
    private func clearAllData() {
        // Clear entries
        for entry in dataManager.entries {
            dataManager.deleteEntry(entry)
        }
        // Clear goals
        for goal in dataManager.goals {
            dataManager.deleteGoal(goal)
        }
    }
    
    // MARK: - Entry Tests
    
    func testCreateEntry() {
        // Given
        let category = Category.defaultCategories.first!
        let amount: Decimal = 25.50
        let note = "Test entry"
        
        // When
        let entry = Entry(
            amount: amount,
            categoryId: category.id,
            note: note
        )
        dataManager.saveEntry(entry)
        
        // Then
        XCTAssertEqual(dataManager.entries.count, 1)
        let savedEntry = dataManager.entries.first!
        XCTAssertEqual(savedEntry.amount, amount)
        XCTAssertEqual(savedEntry.categoryId, category.id)
        XCTAssertEqual(savedEntry.note, note)
    }
    
    func testUpdateEntry() {
        // Given
        let category = Category.defaultCategories.first!
        let entry = Entry(amount: 10.0, categoryId: category.id)
        dataManager.saveEntry(entry)
        
        // When
        var updatedEntry = entry
        updatedEntry.amount = 20.0
        updatedEntry.note = "Updated note"
        dataManager.updateEntry(updatedEntry)
        
        // Then
        XCTAssertEqual(dataManager.entries.count, 1)
        let savedEntry = dataManager.entries.first!
        XCTAssertEqual(savedEntry.amount, 20.0)
        XCTAssertEqual(savedEntry.note, "Updated note")
    }
    
    func testDeleteEntry() {
        // Given
        let category = Category.defaultCategories.first!
        let entry1 = Entry(amount: 10.0, categoryId: category.id)
        let entry2 = Entry(amount: 20.0, categoryId: category.id)
        dataManager.saveEntry(entry1)
        dataManager.saveEntry(entry2)
        
        XCTAssertEqual(dataManager.entries.count, 2)
        
        // When
        dataManager.deleteEntry(entry1)
        
        // Then
        XCTAssertEqual(dataManager.entries.count, 1)
        XCTAssertEqual(dataManager.entries.first!.id, entry2.id)
    }
    
    func testMultipleEntriesPerDay() {
        // Given
        let category = Category.defaultCategories.first!
        let date = Date()
        
        // When
        let entry1 = Entry(amount: 10.0, categoryId: category.id, timestamp: date)
        let entry2 = Entry(amount: 20.0, categoryId: category.id, timestamp: date)
        let entry3 = Entry(amount: 30.0, categoryId: category.id, timestamp: date)
        
        dataManager.saveEntry(entry1)
        dataManager.saveEntry(entry2)
        dataManager.saveEntry(entry3)
        
        // Then
        XCTAssertEqual(dataManager.entries.count, 3)
        let calendar = Calendar.current
        let todayEntries = dataManager.entries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: date)
        }
        XCTAssertEqual(todayEntries.count, 3)
    }
    
    // MARK: - Goal Tests
    
    func testCreateGoal() {
        // Given
        let goal = Goal(
            name: "Test Goal",
            targetAmount: 1000.0,
            period: .monthly
        )
        
        // When
        dataManager.saveGoal(goal)
        
        // Then
        XCTAssertEqual(dataManager.goals.count, 1)
        let savedGoal = dataManager.goals.first!
        XCTAssertEqual(savedGoal.name, "Test Goal")
        XCTAssertEqual(savedGoal.targetAmount, 1000.0)
        XCTAssertEqual(savedGoal.currentAmount, 0)
        XCTAssertFalse(savedGoal.isCompleted)
    }
    
    func testGoalProgressTracking() {
        // Given
        let goal = Goal(
            name: "Test Goal",
            targetAmount: 100.0,
            period: .monthly
        )
        dataManager.saveGoal(goal)
        
        let category = Category.defaultCategories.first!
        
        // When - Add entries that contribute to goal
        let entry1 = Entry(amount: 30.0, categoryId: category.id)
        let entry2 = Entry(amount: 40.0, categoryId: category.id)
        let entry3 = Entry(amount: 30.0, categoryId: category.id)
        
        dataManager.saveEntry(entry1)
        dataManager.saveEntry(entry2)
        dataManager.saveEntry(entry3)
        
        // Then - Goal should be updated
        let updatedGoal = dataManager.goals.first!
        XCTAssertEqual(updatedGoal.currentAmount, 100.0)
        XCTAssertTrue(updatedGoal.isCompleted)
        XCTAssertNotNil(updatedGoal.completedAt)
    }
    
    func testMultipleGoals() {
        // Given
        let goal1 = Goal(name: "Goal 1", targetAmount: 100.0, period: .monthly)
        let goal2 = Goal(name: "Goal 2", targetAmount: 200.0, period: .yearly)
        let goal3 = Goal(name: "Goal 3", targetAmount: 50.0, period: .monthly)
        
        // When
        dataManager.saveGoal(goal1)
        dataManager.saveGoal(goal2)
        dataManager.saveGoal(goal3)
        
        // Then
        XCTAssertEqual(dataManager.goals.count, 3)
    }
    
    func testGoalProgressPercentage() {
        // Given
        let goal = Goal(
            name: "Test Goal",
            targetAmount: 200.0,
            currentAmount: 50.0,
            period: .monthly
        )
        
        // Then
        XCTAssertEqual(goal.progressPercentage, 25.0, accuracy: 0.1)
    }
    
    func testDeleteGoal() {
        // Given
        let goal1 = Goal(name: "Goal 1", targetAmount: 100.0, period: .monthly)
        let goal2 = Goal(name: "Goal 2", targetAmount: 200.0, period: .yearly)
        dataManager.saveGoal(goal1)
        dataManager.saveGoal(goal2)
        
        XCTAssertEqual(dataManager.goals.count, 2)
        
        // When
        dataManager.deleteGoal(goal1)
        
        // Then
        XCTAssertEqual(dataManager.goals.count, 1)
        XCTAssertEqual(dataManager.goals.first!.id, goal2.id)
    }
    
    // MARK: - Streak Tests
    
    func testStreakCalculation() {
        // Given
        let category = Category.defaultCategories.first!
        let calendar = Calendar.current
        var entries: [Entry] = []
        
        // Create entries for 5 consecutive days
        for dayOffset in 0..<5 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let entry = Entry(amount: 10.0, categoryId: category.id, timestamp: date)
                entries.append(entry)
                dataManager.saveEntry(entry)
            }
        }
        
        // When
        var streak = Streak()
        streak.updateWithEntries(dataManager.entries)
        
        // Then
        XCTAssertEqual(streak.currentStreak, 5)
    }
    
    func testStreakResetOnMissedDay() {
        // Given
        let category = Category.defaultCategories.first!
        let calendar = Calendar.current
        
        // Create entries with a gap
        if let date1 = calendar.date(byAdding: .day, value: -3, to: Date()),
           let date2 = calendar.date(byAdding: .day, value: -1, to: Date()) {
            let entry1 = Entry(amount: 10.0, categoryId: category.id, timestamp: date1)
            let entry2 = Entry(amount: 10.0, categoryId: category.id, timestamp: date2)
            dataManager.saveEntry(entry1)
            dataManager.saveEntry(entry2)
        }
        
        // When
        var streak = Streak()
        streak.updateWithEntries(dataManager.entries)
        
        // Then - Streak should only count from most recent entry
        XCTAssertEqual(streak.currentStreak, 1)
    }
    
    func testLongestStreakTracking() {
        // Given
        let category = Category.defaultCategories.first!
        let calendar = Calendar.current
        var entries: [Entry] = []
        
        // Create entries for 10 consecutive days
        for dayOffset in 0..<10 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let entry = Entry(amount: 10.0, categoryId: category.id, timestamp: date)
                entries.append(entry)
                dataManager.saveEntry(entry)
            }
        }
        
        // When
        var streak = Streak()
        streak.updateWithEntries(dataManager.entries)
        
        // Then
        XCTAssertEqual(streak.currentStreak, 10)
        XCTAssertEqual(streak.longestStreak, 10)
    }
    
    // MARK: - Category Tests
    
    func testDefaultCategoriesExist() {
        // When
        let categories = dataManager.categories
        
        // Then
        XCTAssertGreaterThanOrEqual(categories.count, Category.defaultCategories.count)
        
        for defaultCategory in Category.defaultCategories {
            let exists = categories.contains { $0.id == defaultCategory.id }
            XCTAssertTrue(exists, "Default category \(defaultCategory.name) should exist")
        }
    }
    
    func testCustomCategoryCreation() {
        // Given
        let customCategory = Category(
            name: "Custom Category",
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
    
    // MARK: - Export/Import Tests
    
    func testExportData() {
        // Given
        let category = Category.defaultCategories.first!
        let entry1 = Entry(amount: 10.0, categoryId: category.id, note: "Entry 1")
        let entry2 = Entry(amount: 20.0, categoryId: category.id, note: "Entry 2")
        let goal = Goal(name: "Test Goal", targetAmount: 100.0, period: .monthly)
        
        dataManager.saveEntry(entry1)
        dataManager.saveEntry(entry2)
        dataManager.saveGoal(goal)
        
        // When
        guard let exportData = dataManager.exportData() else {
            XCTFail("Export data should not be nil")
            return
        }
        
        // Then
        XCTAssertFalse(exportData.isEmpty)
        
        // Verify JSON structure
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let decoded = try? decoder.decode(ExportData.self, from: exportData) else {
            XCTFail("Should be able to decode export data")
            return
        }
        
        XCTAssertEqual(decoded.entries.count, 2)
        XCTAssertEqual(decoded.goals.count, 1)
    }
    
    func testImportData() {
        // Given - Create export data
        let category = Category.defaultCategories.first!
        let entry1 = Entry(amount: 10.0, categoryId: category.id, note: "Entry 1")
        let entry2 = Entry(amount: 20.0, categoryId: category.id, note: "Entry 2")
        let goal = Goal(name: "Test Goal", targetAmount: 100.0, period: .monthly)
        
        dataManager.saveEntry(entry1)
        dataManager.saveEntry(entry2)
        dataManager.saveGoal(goal)
        
        guard let exportData = dataManager.exportData() else {
            XCTFail("Export data should not be nil")
            return
        }
        
        // Clear data
        clearAllData()
        XCTAssertEqual(dataManager.entries.count, 0)
        XCTAssertEqual(dataManager.goals.count, 0)
        
        // When
        let success = dataManager.importData(exportData)
        
        // Then
        XCTAssertTrue(success)
        XCTAssertEqual(dataManager.entries.count, 2)
        XCTAssertEqual(dataManager.goals.count, 1)
    }
    
    // MARK: - Home ViewModel Tests
    
    func testHomeViewModelTodayStats() {
        // Given
        let category = Category.defaultCategories.first!
        let today = Date()
        
        let entry1 = Entry(amount: 10.0, categoryId: category.id, timestamp: today)
        let entry2 = Entry(amount: 20.0, categoryId: category.id, timestamp: today)
        let entry3 = Entry(amount: 15.0, categoryId: category.id, timestamp: today)
        
        dataManager.saveEntry(entry1)
        dataManager.saveEntry(entry2)
        dataManager.saveEntry(entry3)
        
        // When
        let viewModel = HomeViewModel()
        let expectation = XCTestExpectation(description: "Wait for data update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(viewModel.todayTotal, 45.0)
        XCTAssertEqual(viewModel.todayEntryCount, 3)
    }
    
    func testHomeViewModelActiveGoals() {
        // Given
        let goal1 = Goal(name: "Goal 1", targetAmount: 100.0, period: .monthly)
        let goal2 = Goal(name: "Goal 2", targetAmount: 200.0, period: .yearly)
        let goal3 = Goal(
            name: "Goal 3",
            targetAmount: 50.0,
            period: .monthly,
            isCompleted: true
        )
        
        dataManager.saveGoal(goal1)
        dataManager.saveGoal(goal2)
        dataManager.saveGoal(goal3)
        
        // When
        let viewModel = HomeViewModel()
        let expectation = XCTestExpectation(description: "Wait for data update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(viewModel.activeGoals.count, 2)
        XCTAssertFalse(viewModel.activeGoals.contains { $0.id == goal3.id })
    }
    
    // MARK: - History ViewModel Tests
    
    func testHistoryViewModelFiltering() {
        // Given
        let category1 = Category.defaultCategories[0]
        let category2 = Category.defaultCategories[1]
        
        let entry1 = Entry(amount: 10.0, categoryId: category1.id, note: "Test 1")
        let entry2 = Entry(amount: 20.0, categoryId: category2.id, note: "Test 2")
        let entry3 = Entry(amount: 30.0, categoryId: category1.id, note: "Test 3")
        
        dataManager.saveEntry(entry1)
        dataManager.saveEntry(entry2)
        dataManager.saveEntry(entry3)
        
        // When
        let viewModel = HistoryViewModel()
        viewModel.filters.selectedCategories = [category1.id]
        
        let expectation = XCTestExpectation(description: "Wait for filtering")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        let filteredCategoryIds = Set(viewModel.filteredEntries.map { $0.categoryId })
        XCTAssertTrue(filteredCategoryIds.isSubset(of: [category1.id]))
        XCTAssertEqual(viewModel.filteredEntries.count, 2)
    }
    
    func testHistoryViewModelSearch() {
        // Given
        let category = Category.defaultCategories.first!
        let entry1 = Entry(amount: 10.0, categoryId: category.id, note: "Coffee savings")
        let entry2 = Entry(amount: 20.0, categoryId: category.id, note: "Lunch savings")
        let entry3 = Entry(amount: 30.0, categoryId: category.id, note: "Coffee again")
        
        dataManager.saveEntry(entry1)
        dataManager.saveEntry(entry2)
        dataManager.saveEntry(entry3)
        
        // When
        let viewModel = HistoryViewModel()
        viewModel.searchText = "Coffee"
        
        let expectation = XCTestExpectation(description: "Wait for search")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(viewModel.filteredEntries.count, 2)
        XCTAssertTrue(viewModel.filteredEntries.allSatisfy { $0.note?.contains("Coffee") ?? false })
    }
    
    // MARK: - Goals ViewModel Tests
    
    func testGoalsViewModelActiveAndCompleted() {
        // Given
        let activeGoal1 = Goal(name: "Active 1", targetAmount: 100.0, period: .monthly)
        let activeGoal2 = Goal(name: "Active 2", targetAmount: 200.0, period: .yearly)
        let completedGoal = Goal(
            name: "Completed",
            targetAmount: 50.0,
            currentAmount: 50.0,
            period: .monthly,
            isCompleted: true,
            completedAt: Date()
        )
        
        dataManager.saveGoal(activeGoal1)
        dataManager.saveGoal(activeGoal2)
        dataManager.saveGoal(completedGoal)
        
        // When
        let viewModel = GoalsViewModel()
        let expectation = XCTestExpectation(description: "Wait for data update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(viewModel.activeGoals.count, 2)
        XCTAssertEqual(viewModel.completedGoals.count, 1)
        XCTAssertTrue(viewModel.activeGoals.allSatisfy { !$0.isCompleted })
        XCTAssertTrue(viewModel.completedGoals.allSatisfy { $0.isCompleted })
    }
    
    // MARK: - Settings ViewModel Tests
    
    func testSettingsViewModelPersistence() {
        // Given
        let viewModel = SettingsViewModel()
        viewModel.currency = "EUR"
        viewModel.theme = .dark
        viewModel.hasCompletedOnboarding = true
        
        // When - Create new instance
        let newViewModel = SettingsViewModel()
        
        // Then
        XCTAssertEqual(newViewModel.currency, "EUR")
        XCTAssertEqual(newViewModel.theme, .dark)
        XCTAssertTrue(newViewModel.hasCompletedOnboarding)
    }
    
    func testSettingsViewModelExport() {
        // Given
        let category = Category.defaultCategories.first!
        let entry = Entry(amount: 10.0, categoryId: category.id)
        dataManager.saveEntry(entry)
        
        // When
        let viewModel = SettingsViewModel()
        let jsonData = viewModel.exportData(format: .json)
        let csvData = viewModel.exportData(format: .csv)
        
        // Then
        XCTAssertNotNil(jsonData)
        XCTAssertNotNil(csvData)
        XCTAssertFalse(jsonData!.isEmpty)
        XCTAssertFalse(csvData!.isEmpty)
    }
}
