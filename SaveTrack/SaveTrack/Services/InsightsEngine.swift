import Foundation

struct Insight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let message: String
    let emoji: String
    let priority: Priority
    
    enum InsightType {
        case streak
        case goal
        case pattern
        case recommendation
        case achievement
    }
    
    enum Priority {
        case high
        case medium
        case low
    }
}

class InsightsEngine {
    private let dataManager = DataManager.shared
    
    func generateInsights(entries: [Entry], goals: [Goal], streak: Streak) -> [Insight] {
        var insights: [Insight] = []
        
        // Streak insights
        insights.append(contentsOf: generateStreakInsights(streak: streak))
        
        // Goal insights
        insights.append(contentsOf: generateGoalInsights(goals: goals))
        
        // Pattern insights
        insights.append(contentsOf: generatePatternInsights(entries: entries))
        
        // Recommendations
        insights.append(contentsOf: generateRecommendations(entries: entries, goals: goals))
        
        // Sort by priority
        return insights.sorted { insight1, insight2 in
            let priorityOrder: [Insight.Priority] = [.high, .medium, .low]
            let index1 = priorityOrder.firstIndex(of: insight1.priority) ?? 999
            let index2 = priorityOrder.firstIndex(of: insight2.priority) ?? 999
            return index1 < index2
        }
    }
    
    private func generateStreakInsights(streak: Streak) -> [Insight] {
        var insights: [Insight] = []
        
        if streak.currentStreak >= 7 && streak.currentStreak < 30 {
            insights.append(Insight(
                type: .streak,
                title: "Great Start!",
                message: "You've maintained a \(streak.currentStreak)-day streak. Keep it up to reach 30 days!",
                emoji: "🔥",
                priority: .high
            ))
        }
        
        if streak.currentStreak > 0 && streak.currentStreak < streak.longestStreak {
            let daysToBeat = streak.longestStreak - streak.currentStreak
            insights.append(Insight(
                type: .streak,
                title: "Beat Your Record!",
                message: "You're \(daysToBeat) days away from beating your longest streak of \(streak.longestStreak) days.",
                emoji: "🏆",
                priority: .medium
            ))
        }
        
        if let nextMilestone = streak.nextMilestone {
            let daysToMilestone = nextMilestone - streak.currentStreak
            insights.append(Insight(
                type: .achievement,
                title: "Milestone Approaching",
                message: "Just \(daysToMilestone) more days to earn your \(nextMilestone)-day badge!",
                emoji: "⭐",
                priority: .high
            ))
        }
        
        return insights
    }
    
    private func generateGoalInsights(goals: [Goal]) -> [Insight] {
        var insights: [Insight] = []
        
        let activeGoals = goals.filter { $0.isActive }
        
        for goal in activeGoals {
            let progress = goal.progressPercentage
            let remaining = goal.targetAmount - goal.currentAmount
            
            if progress >= 75 && progress < 100 {
                insights.append(Insight(
                    type: .goal,
                    title: "Almost There!",
                    message: "You're \(Int(progress))% towards '\(goal.name)'. Just \(formatCurrency(remaining)) to go!",
                    emoji: "🎯",
                    priority: .high
                ))
            } else if progress >= 50 && progress < 75 {
                insights.append(Insight(
                    type: .goal,
                    title: "Halfway There!",
                    message: "You've reached \(Int(progress))% of '\(goal.name)'. Keep up the momentum!",
                    emoji: "💪",
                    priority: .medium
                ))
            }
            
            if let daysRemaining = goal.daysRemaining, daysRemaining <= 7 {
                let dailyNeeded = remaining / Decimal(daysRemaining)
                insights.append(Insight(
                    type: .goal,
                    title: "Time to Push!",
                    message: "Only \(daysRemaining) days left for '\(goal.name)'. Save \(formatCurrency(dailyNeeded)) per day to reach it!",
                    emoji: "⏰",
                    priority: .high
                ))
            }
        }
        
        if activeGoals.isEmpty {
            insights.append(Insight(
                type: .recommendation,
                title: "Set a Goal",
                message: "Create a savings goal to stay motivated and track your progress!",
                emoji: "🎯",
                priority: .medium
            ))
        }
        
        return insights
    }
    
    private func generatePatternInsights(entries: [Entry]) -> [Insight] {
        var insights: [Insight] = []
        
        guard entries.count >= 7 else { return insights }
        
        let calendar = Calendar.current
        let last30Days = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentEntries = entries.filter { $0.timestamp >= last30Days }
        
        // Best day of week
        let dayOfWeekTotals = Dictionary(grouping: recentEntries) { entry in
            calendar.component(.weekday, from: entry.timestamp)
        }.mapValues { entries in
            (entries.reduce(Decimal(0)) { $0 + $1.amount }, entries.count)
        }
        
        if let bestDay = dayOfWeekTotals.max(by: { $0.value.0 < $1.value.0 }) {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEEE"
            let dayName = dayFormatter.weekdaySymbols[bestDay.key - 1]
            insights.append(Insight(
                type: .pattern,
                title: "Your Best Day",
                message: "You save the most on \(dayName)s. Average: \(formatCurrency(bestDay.value.0 / Decimal(bestDay.value.1)))",
                emoji: "📅",
                priority: .low
            ))
        }
        
        // Best category
        let categoryTotals = Dictionary(grouping: recentEntries) { $0.categoryId }
            .mapValues { entries in
                entries.reduce(Decimal(0)) { $0 + $1.amount }
            }
        
        if let bestCategoryId = categoryTotals.max(by: { $0.value < $1.value })?.key,
           let category = dataManager.categories.first(where: { $0.id == bestCategoryId }) {
            let categoryTotal = bestCategoryId.value
            let percentage = (categoryTotal / recentEntries.reduce(Decimal(0)) { $0 + $1.amount }) * 100
            insights.append(Insight(
                type: .pattern,
                title: "Top Category",
                message: "\(category.emoji) \(category.name) accounts for \(Int(percentage))% of your savings.",
                emoji: category.emoji,
                priority: .low
            ))
        }
        
        // Consistency check
        let daysWithEntries = Set(recentEntries.map { calendar.startOfDay(for: $0.timestamp) }).count
        let consistency = Double(daysWithEntries) / 30.0
        
        if consistency < 0.5 {
            insights.append(Insight(
                type: .recommendation,
                title: "Build Consistency",
                message: "Try logging entries more regularly to build a stronger habit.",
                emoji: "🔄",
                priority: .medium
            ))
        }
        
        return insights
    }
    
    private func generateRecommendations(entries: [Entry], goals: [Goal]) -> [Insight] {
        var insights: [Insight] = []
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayEntries = entries.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
        
        if todayEntries.isEmpty {
            insights.append(Insight(
                type: .recommendation,
                title: "Log Today's Savings",
                message: "Don't forget to log your savings for today to maintain your streak!",
                emoji: "📝",
                priority: .high
            ))
        }
        
        // Average savings recommendation
        if entries.count >= 7 {
            let last7Days = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            let weekEntries = entries.filter { $0.timestamp >= last7Days }
            let weekTotal = weekEntries.reduce(Decimal(0)) { $0 + $1.amount }
            let dailyAverage = weekTotal / Decimal(7)
            
            insights.append(Insight(
                type: .recommendation,
                title: "Your Average",
                message: "You're saving \(formatCurrency(dailyAverage)) per day on average. Great job!",
                emoji: "📊",
                priority: .low
            ))
        }
        
        return insights
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}
