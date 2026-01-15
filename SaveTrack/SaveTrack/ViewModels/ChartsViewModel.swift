import Foundation
import Combine

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Decimal
}

struct CategoryChartData: Identifiable {
    let id = UUID()
    let categoryId: UUID
    let categoryName: String
    let categoryEmoji: String
    let amount: Decimal
    let percentage: Double
}

class ChartsViewModel: ObservableObject {
    @Published var chartData: [ChartDataPoint] = []
    @Published var categoryData: [CategoryChartData] = []
    @Published var totalSaved: Decimal = 0
    @Published var averagePerDay: Decimal = 0
    @Published var totalEntries: Int = 0
    @Published var topCategory: String = ""
    
    private let dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
    }
    
    enum ChartType: String, CaseIterable {
        case line = "Line"
        case bar = "Bar"
        case trend = "Trend"
    }
    
    @Published var selectedPeriod: TimePeriod = .month
    @Published var selectedChartType: ChartType = .line
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        dataManager.$entries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateData()
            }
            .store(in: &cancellables)
    }
    
    func updateData() {
        updateChartData()
        updateCategoryData()
        updateSummaryStats()
    }
    
    private func updateChartData() {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedPeriod.days, to: endDate) ?? endDate
        
        let filteredEntries = dataManager.entries.filter { entry in
            entry.timestamp >= startDate && entry.timestamp <= endDate
        }
        
        // Group by date and sum amounts
        let groupedByDate = Dictionary(grouping: filteredEntries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        
        var cumulativeAmount: Decimal = 0
        var dataPoints: [ChartDataPoint] = []
        
        let sortedDates = groupedByDate.keys.sorted()
        
        for date in sortedDates {
            let dayEntries = groupedByDate[date] ?? []
            let dayTotal = dayEntries.reduce(Decimal(0)) { $0 + $1.amount }
            cumulativeAmount += dayTotal
            dataPoints.append(ChartDataPoint(date: date, amount: cumulativeAmount))
        }
        
        chartData = dataPoints
    }
    
    private func updateCategoryData() {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedPeriod.days, to: endDate) ?? endDate
        
        let filteredEntries = dataManager.entries.filter { entry in
            entry.timestamp >= startDate && entry.timestamp <= endDate
        }
        
        let total = filteredEntries.reduce(Decimal(0)) { $0 + $1.amount }
        
        // Group by category
        let groupedByCategory = Dictionary(grouping: filteredEntries) { $0.categoryId }
        
        var categoryDataPoints: [CategoryChartData] = []
        
        for (categoryId, entries) in groupedByCategory {
            let categoryTotal = entries.reduce(Decimal(0)) { $0 + $1.amount }
            let percentage = total > 0 ? Double(truncating: (categoryTotal / total * 100) as NSDecimalNumber) : 0
            
            if let category = dataManager.categories.first(where: { $0.id == categoryId }) {
                categoryDataPoints.append(CategoryChartData(
                    categoryId: categoryId,
                    categoryName: category.name,
                    categoryEmoji: category.emoji,
                    amount: categoryTotal,
                    percentage: percentage
                ))
            }
        }
        
        categoryData = categoryDataPoints.sorted { $0.amount > $1.amount }
    }
    
    private func updateSummaryStats() {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedPeriod.days, to: endDate) ?? endDate
        
        let filteredEntries = dataManager.entries.filter { entry in
            entry.timestamp >= startDate && entry.timestamp <= endDate
        }
        
        totalSaved = filteredEntries.reduce(Decimal(0)) { $0 + $1.amount }
        totalEntries = filteredEntries.count
        
        let days = selectedPeriod.days
        averagePerDay = days > 0 ? totalSaved / Decimal(days) : 0
        
        // Find top category
        let groupedByCategory = Dictionary(grouping: filteredEntries) { $0.categoryId }
        if let topCategoryId = groupedByCategory.max(by: { category1, category2 in
            let total1 = category1.value.reduce(Decimal(0)) { $0 + $1.amount }
            let total2 = category2.value.reduce(Decimal(0)) { $0 + $1.amount }
            return total1 < total2
        })?.key,
        let category = dataManager.categories.first(where: { $0.id == topCategoryId }) {
            topCategory = "\(category.emoji) \(category.name)"
        } else {
            topCategory = "None"
        }
    }
    
    func chartData(for period: TimePeriod) -> [ChartDataPoint] {
        selectedPeriod = period
        updateChartData()
        return chartData
    }
    
    func categoryData(for period: TimePeriod) -> [CategoryChartData] {
        selectedPeriod = period
        updateCategoryData()
        return categoryData
    }
    
    // MARK: - Bar Chart Data (Monthly Comparisons)
    
    @Published var monthlyComparisonData: [MonthlyComparisonData] = []
    
    struct MonthlyComparisonData: Identifiable {
        let id = UUID()
        let month: String
        let amount: Decimal
        let entryCount: Int
    }
    
    func updateMonthlyComparison() {
        let calendar = Calendar.current
        let now = Date()
        var monthlyData: [MonthlyComparisonData] = []
        
        // Get last 6 months
        for monthOffset in 0..<6 {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: now) else { continue }
            
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))!
            let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
            
            let monthEntries = dataManager.entries.filter { entry in
                entry.timestamp >= monthStart && entry.timestamp <= monthEnd
            }
            
            let monthTotal = monthEntries.reduce(Decimal(0)) { $0 + $1.amount }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            
            monthlyData.append(MonthlyComparisonData(
                month: formatter.string(from: monthDate),
                amount: monthTotal,
                entryCount: monthEntries.count
            ))
        }
        
        monthlyComparisonData = monthlyData.reversed()
    }
    
    // MARK: - Trend Analysis
    
    @Published var trendData: TrendData?
    
    struct TrendData {
        let weeklyGrowth: Double
        let monthlyGrowth: Double
        let averageDailySavings: Decimal
        let bestDayOfWeek: String
        let bestCategory: String
    }
    
    func updateTrendAnalysis() {
        let calendar = Calendar.current
        let now = Date()
        
        // Last week
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return }
        let lastWeekEntries = dataManager.entries.filter { $0.timestamp >= weekAgo && $0.timestamp < now }
        let lastWeekTotal = lastWeekEntries.reduce(Decimal(0)) { $0 + $1.amount }
        
        // Previous week
        guard let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now),
              let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return }
        let previousWeekEntries = dataManager.entries.filter { $0.timestamp >= twoWeeksAgo && $0.timestamp < oneWeekAgo }
        let previousWeekTotal = previousWeekEntries.reduce(Decimal(0)) { $0 + $1.amount }
        
        // Last month
        guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) else { return }
        let lastMonthEntries = dataManager.entries.filter { $0.timestamp >= monthAgo && $0.timestamp < now }
        let lastMonthTotal = lastMonthEntries.reduce(Decimal(0)) { $0 + $1.amount }
        
        // Previous month
        guard let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: now),
              let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) else { return }
        let previousMonthEntries = dataManager.entries.filter { $0.timestamp >= twoMonthsAgo && $0.timestamp < oneMonthAgo }
        let previousMonthTotal = previousMonthEntries.reduce(Decimal(0)) { $0 + $1.amount }
        
        // Calculate growth
        let weeklyGrowth = previousWeekTotal > 0 ? 
            Double(truncating: ((lastWeekTotal - previousWeekTotal) / previousWeekTotal * 100) as NSDecimalNumber) : 0
        let monthlyGrowth = previousMonthTotal > 0 ?
            Double(truncating: ((lastMonthTotal - previousMonthTotal) / previousMonthTotal * 100) as NSDecimalNumber) : 0
        
        // Average daily savings (last 30 days)
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        let recentEntries = dataManager.entries.filter { $0.timestamp >= thirtyDaysAgo }
        let recentTotal = recentEntries.reduce(Decimal(0)) { $0 + $1.amount }
        let averageDaily = recentTotal / Decimal(30)
        
        // Best day of week
        let dayOfWeekTotals = Dictionary(grouping: recentEntries) { entry in
            calendar.component(.weekday, from: entry.timestamp)
        }.mapValues { entries in
            entries.reduce(Decimal(0)) { $0 + $1.amount }
        }
        
        let bestDayNumber = dayOfWeekTotals.max(by: { $0.value < $1.value })?.key ?? 1
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let bestDay = dayFormatter.weekdaySymbols[bestDayNumber - 1]
        
        // Best category
        let categoryTotals = Dictionary(grouping: recentEntries) { $0.categoryId }
            .mapValues { entries in
                entries.reduce(Decimal(0)) { $0 + $1.amount }
            }
        
        if let bestCategoryId = categoryTotals.max(by: { $0.value < $1.value })?.key,
           let category = dataManager.categories.first(where: { $0.id == bestCategoryId }) {
            trendData = TrendData(
                weeklyGrowth: weeklyGrowth,
                monthlyGrowth: monthlyGrowth,
                averageDailySavings: averageDaily,
                bestDayOfWeek: bestDay,
                bestCategory: category.name
            )
        }
    }
    
    // MARK: - Week-over-Week Comparison
    
    @Published var weekOverWeekData: [WeekComparisonData] = []
    
    struct WeekComparisonData: Identifiable {
        let id = UUID()
        let weekLabel: String
        let amount: Decimal
        let entryCount: Int
    }
    
    func updateWeekOverWeek() {
        let calendar = Calendar.current
        let now = Date()
        var weekData: [WeekComparisonData] = []
        
        // Get last 4 weeks
        for weekOffset in 0..<4 {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now),
                  let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else { continue }
            
            let weekEntries = dataManager.entries.filter { entry in
                entry.timestamp >= weekStart && entry.timestamp <= weekEnd
            }
            
            let weekTotal = weekEntries.reduce(Decimal(0)) { $0 + $1.amount }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            
            weekData.append(WeekComparisonData(
                weekLabel: "Week \(weekOffset + 1)",
                amount: weekTotal,
                entryCount: weekEntries.count
            ))
        }
        
        weekOverWeekData = weekData.reversed()
    }
}
