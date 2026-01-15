import XCTest
@testable import SaveTrack

final class Phase3IntegrationTests: XCTestCase {
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
    
    // MARK: - Additional Chart Types Tests
    
    func testMonthlyComparisonData() {
        // Given
        let category = Category.defaultCategories.first!
        let calendar = Calendar.current
        
        // Create entries over last 3 months
        for monthOffset in 0..<3 {
            if let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) {
                let entry = Entry(
                    amount: Decimal(monthOffset + 1) * 100,
                    categoryId: category.id,
                    timestamp: monthDate
                )
                dataManager.saveEntry(entry)
            }
        }
        
        // When
        let viewModel = ChartsViewModel()
        viewModel.updateMonthlyComparison()
        
        // Then
        XCTAssertGreaterThan(viewModel.monthlyComparisonData.count, 0)
    }
    
    func testWeekOverWeekData() {
        // Given
        let category = Category.defaultCategories.first!
        let calendar = Calendar.current
        
        // Create entries for last 2 weeks
        for weekOffset in 0..<2 {
            if let weekDate = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date()) {
                let entry = Entry(
                    amount: Decimal(weekOffset + 1) * 50,
                    categoryId: category.id,
                    timestamp: weekDate
                )
                dataManager.saveEntry(entry)
            }
        }
        
        // When
        let viewModel = ChartsViewModel()
        viewModel.updateWeekOverWeek()
        
        // Then
        XCTAssertGreaterThan(viewModel.weekOverWeekData.count, 0)
    }
    
    func testTrendAnalysis() {
        // Given
        let category = Category.defaultCategories.first!
        let calendar = Calendar.current
        
        // Create entries over last 2 months
        for dayOffset in 0..<60 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let entry = Entry(
                    amount: Decimal(dayOffset % 7 + 1) * 10,
                    categoryId: category.id,
                    timestamp: date
                )
                dataManager.saveEntry(entry)
            }
        }
        
        // When
        let viewModel = ChartsViewModel()
        viewModel.updateTrendAnalysis()
        
        // Then
        XCTAssertNotNil(viewModel.trendData)
        if let trend = viewModel.trendData {
            XCTAssertNotNil(trend.bestDayOfWeek)
            XCTAssertNotNil(trend.bestCategory)
        }
    }
    
    // MARK: - Entry Template Tests
    
    func testCreateEntryTemplate() {
        // Given
        let category = Category.defaultCategories.first!
        let template = EntryTemplate(
            name: "Coffee Savings",
            amount: 5.50,
            categoryId: category.id,
            note: "Daily coffee"
        )
        
        // When
        let viewModel = EntryTemplateViewModel()
        viewModel.saveTemplate(template)
        
        // Then
        XCTAssertEqual(viewModel.templates.count, 1)
        XCTAssertEqual(viewModel.templates.first?.name, "Coffee Savings")
    }
    
    func testCreateEntryFromTemplate() {
        // Given
        let category = Category.defaultCategories.first!
        let template = EntryTemplate(
            name: "Test Template",
            amount: 25.0,
            categoryId: category.id,
            note: "Test note"
        )
        
        // When
        let entry = template.toEntry()
        
        // Then
        XCTAssertEqual(entry.amount, 25.0)
        XCTAssertEqual(entry.categoryId, category.id)
        XCTAssertEqual(entry.note, "Test note")
    }
    
    func testDeleteTemplate() {
        // Given
        let category = Category.defaultCategories.first!
        let template1 = EntryTemplate(name: "Template 1", amount: 10.0, categoryId: category.id)
        let template2 = EntryTemplate(name: "Template 2", amount: 20.0, categoryId: category.id)
        
        let viewModel = EntryTemplateViewModel()
        viewModel.saveTemplate(template1)
        viewModel.saveTemplate(template2)
        
        XCTAssertEqual(viewModel.templates.count, 2)
        
        // When
        viewModel.deleteTemplate(template1)
        
        // Then
        XCTAssertEqual(viewModel.templates.count, 1)
        XCTAssertEqual(viewModel.templates.first?.name, "Template 2")
    }
    
    // MARK: - Insights Engine Tests
    
    func testInsightsGeneration() {
        // Given
        let category = Category.defaultCategories.first!
        let calendar = Calendar.current
        
        // Create entries for 10 days
        for dayOffset in 0..<10 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let entry = Entry(amount: 10.0, categoryId: category.id, timestamp: date)
                dataManager.saveEntry(entry)
            }
        }
        
        let goal = Goal(name: "Test Goal", targetAmount: 100.0, period: .monthly)
        dataManager.saveGoal(goal)
        
        var streak = Streak()
        streak.updateWithEntries(dataManager.entries)
        
        // When
        let engine = InsightsEngine()
        let insights = engine.generateInsights(
            entries: dataManager.entries,
            goals: dataManager.goals,
            streak: streak
        )
        
        // Then
        XCTAssertGreaterThan(insights.count, 0)
    }
    
    func testStreakInsights() {
        // Given
        let category = Category.defaultCategories.first!
        let calendar = Calendar.current
        
        // Create entries for 8 days (approaching 7-day milestone)
        for dayOffset in 0..<8 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let entry = Entry(amount: 10.0, categoryId: category.id, timestamp: date)
                dataManager.saveEntry(entry)
            }
        }
        
        var streak = Streak()
        streak.updateWithEntries(dataManager.entries)
        
        // When
        let engine = InsightsEngine()
        let insights = engine.generateInsights(
            entries: dataManager.entries,
            goals: [],
            streak: streak
        )
        
        // Then
        let streakInsights = insights.filter { $0.type == .streak || $0.type == .achievement }
        XCTAssertGreaterThan(streakInsights.count, 0)
    }
    
    func testGoalInsights() {
        // Given
        let goal = Goal(
            name: "Test Goal",
            targetAmount: 100.0,
            currentAmount: 80.0,
            period: .monthly
        )
        dataManager.saveGoal(goal)
        
        // When
        let engine = InsightsEngine()
        let insights = engine.generateInsights(
            entries: [],
            goals: dataManager.goals,
            streak: Streak()
        )
        
        // Then
        let goalInsights = insights.filter { $0.type == .goal }
        XCTAssertGreaterThan(goalInsights.count, 0)
    }
    
    // MARK: - Shareable Image Generator Tests
    
    func testGoalAchievementImageGeneration() {
        // Given
        let goal = Goal(
            name: "Test Goal",
            targetAmount: 1000.0,
            currentAmount: 1000.0,
            period: .monthly,
            isCompleted: true
        )
        
        // When
        let image = ShareableImageGenerator.shared.generateGoalAchievementImage(goal: goal)
        
        // Then
        XCTAssertNotNil(image)
    }
    
    func testBadgeImageGeneration() {
        // Given
        let badge = Badge(
            id: 7,
            name: "Week Warrior",
            emoji: "🔥",
            description: "7 days",
            earnedDate: Date()
        )
        
        // When
        let image = ShareableImageGenerator.shared.generateBadgeImage(badge: badge)
        
        // Then
        XCTAssertNotNil(image)
    }
    
    func testStreakImageGeneration() {
        // Given
        var streak = Streak()
        streak.currentStreak = 15
        streak.longestStreak = 23
        
        // When
        let image = ShareableImageGenerator.shared.generateStreakImage(streak: streak)
        
        // Then
        XCTAssertNotNil(image)
    }
    
    func testMonthlySummaryImageGeneration() {
        // Given
        let totalSaved: Decimal = 500.0
        let entryCount = 30
        let topCategory = "Cooked at Home"
        
        // When
        let image = ShareableImageGenerator.shared.generateMonthlySummaryImage(
            totalSaved: totalSaved,
            entryCount: entryCount,
            topCategory: topCategory
        )
        
        // Then
        XCTAssertNotNil(image)
    }
}
