import XCTest
@testable import SaveTrack

final class ModelTests: XCTestCase {
    
    // MARK: - Entry Model Tests
    
    func testEntryInitialization() {
        let category = Category.defaultCategories.first!
        let entry = Entry(
            amount: 25.50,
            categoryId: category.id,
            note: "Test note"
        )
        
        XCTAssertEqual(entry.amount, 25.50)
        XCTAssertEqual(entry.categoryId, category.id)
        XCTAssertEqual(entry.note, "Test note")
        XCTAssertNotNil(entry.id)
        XCTAssertNotNil(entry.timestamp)
    }
    
    func testEntryFormattedAmount() {
        let category = Category.defaultCategories.first!
        let entry = Entry(amount: 25.50, categoryId: category.id)
        
        let formatted = entry.formattedAmount
        XCTAssertTrue(formatted.contains("$"))
        XCTAssertTrue(formatted.contains("25"))
    }
    
    func testEntryIsToday() {
        let category = Category.defaultCategories.first!
        let todayEntry = Entry(amount: 10.0, categoryId: category.id, timestamp: Date())
        
        XCTAssertTrue(todayEntry.isToday)
        XCTAssertFalse(todayEntry.isYesterday)
    }
    
    // MARK: - Goal Model Tests
    
    func testGoalInitialization() {
        let goal = Goal(
            name: "Test Goal",
            targetAmount: 1000.0,
            period: .monthly
        )
        
        XCTAssertEqual(goal.name, "Test Goal")
        XCTAssertEqual(goal.targetAmount, 1000.0)
        XCTAssertEqual(goal.currentAmount, 0)
        XCTAssertEqual(goal.period, .monthly)
        XCTAssertFalse(goal.isCompleted)
    }
    
    func testGoalProgressPercentage() {
        let goal = Goal(
            name: "Test Goal",
            targetAmount: 200.0,
            currentAmount: 50.0,
            period: .monthly
        )
        
        XCTAssertEqual(goal.progressPercentage, 25.0, accuracy: 0.1)
    }
    
    func testGoalAddAmount() {
        var goal = Goal(
            name: "Test Goal",
            targetAmount: 100.0,
            currentAmount: 0,
            period: .monthly
        )
        
        goal.addAmount(50.0)
        XCTAssertEqual(goal.currentAmount, 50.0)
        XCTAssertFalse(goal.isCompleted)
        
        goal.addAmount(50.0)
        XCTAssertEqual(goal.currentAmount, 100.0)
        XCTAssertTrue(goal.isCompleted)
        XCTAssertNotNil(goal.completedAt)
    }
    
    func testGoalIsActive() {
        let activeGoal = Goal(
            name: "Active",
            targetAmount: 100.0,
            period: .monthly,
            endDate: Date().addingTimeInterval(86400 * 30) // 30 days from now
        )
        
        let completedGoal = Goal(
            name: "Completed",
            targetAmount: 100.0,
            currentAmount: 100.0,
            period: .monthly,
            isCompleted: true
        )
        
        XCTAssertTrue(activeGoal.isActive)
        XCTAssertFalse(completedGoal.isActive)
    }
    
    // MARK: - Category Model Tests
    
    func testDefaultCategories() {
        let categories = Category.defaultCategories
        
        XCTAssertEqual(categories.count, 6)
        XCTAssertTrue(categories.contains { $0.name == "Skipped Purchase" })
        XCTAssertTrue(categories.contains { $0.name == "Used Coupon" })
        XCTAssertTrue(categories.contains { $0.name == "Cooked at Home" })
        XCTAssertTrue(categories.contains { $0.name == "Canceled Subscription" })
        XCTAssertTrue(categories.contains { $0.name == "Cheaper Option" })
        XCTAssertTrue(categories.contains { $0.name == "Other" })
    }
    
    // MARK: - Streak Model Tests
    
    func testStreakInitialization() {
        let streak = Streak()
        
        XCTAssertEqual(streak.currentStreak, 0)
        XCTAssertEqual(streak.longestStreak, 0)
        XCTAssertNil(streak.lastEntryDate)
        XCTAssertFalse(streak.hasActiveStreak)
    }
    
    func testStreakUpdateWithConsecutiveDays() {
        let category = Category.defaultCategories.first!
        let calendar = Calendar.current
        var entries: [Entry] = []
        
        // Create entries for 5 consecutive days
        for dayOffset in 0..<5 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                entries.append(Entry(amount: 10.0, categoryId: category.id, timestamp: date))
            }
        }
        
        var streak = Streak()
        streak.updateWithEntries(entries)
        
        XCTAssertEqual(streak.currentStreak, 5)
        XCTAssertEqual(streak.longestStreak, 5)
    }
    
    func testStreakMilestoneBadges() {
        let category = Category.defaultCategories.first!
        let calendar = Calendar.current
        var entries: [Entry] = []
        
        // Create entries for 7 consecutive days
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                entries.append(Entry(amount: 10.0, categoryId: category.id, timestamp: date))
            }
        }
        
        var streak = Streak()
        streak.updateWithEntries(entries)
        
        XCTAssertTrue(streak.milestoneBadges.contains(7))
    }
    
    // MARK: - AppSettings Model Tests
    
    func testAppSettingsDefault() {
        let settings = AppSettings.default
        
        XCTAssertEqual(settings.currency, "USD")
        XCTAssertEqual(settings.theme, .system)
        XCTAssertFalse(settings.dailyReminderEnabled)
        XCTAssertFalse(settings.hasCompletedOnboarding)
    }
    
    func testAppSettingsCodable() {
        var settings = AppSettings.default
        settings.currency = "EUR"
        settings.theme = .dark
        settings.hasCompletedOnboarding = true
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        guard let data = try? encoder.encode(settings),
              let decoded = try? decoder.decode(AppSettings.self, from: data) else {
            XCTFail("Should be able to encode and decode settings")
            return
        }
        
        XCTAssertEqual(decoded.currency, "EUR")
        XCTAssertEqual(decoded.theme, .dark)
        XCTAssertTrue(decoded.hasCompletedOnboarding)
    }
}
