import Foundation
import Combine
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var streak: Streak = Streak()
    @Published var todayTotal: Decimal = 0
    @Published var todayEntryCount: Int = 0
    @Published var activeGoals: [Goal] = []
    @Published var greeting: String = ""
    
    private let dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        updateGreeting()
    }
    
    private func setupBindings() {
        dataManager.$entries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entries in
                self?.updateStreak(entries: entries)
                self?.updateTodayStats(entries: entries)
            }
            .store(in: &cancellables)
        
        dataManager.$goals
            .receive(on: DispatchQueue.main)
            .sink { [weak self] goals in
                self?.updateActiveGoals(goals: goals)
            }
            .store(in: &cancellables)
    }
    
    private func updateStreak(entries: [Entry]) {
        var newStreak = streak
        newStreak.updateWithEntries(entries)
        
        // Check for newly earned badges
        let previousBadges = streak.milestoneBadges
        let newBadges = newStreak.milestoneBadges.subtracting(previousBadges)
        
        if !newBadges.isEmpty {
            for badgeId in newBadges {
                if let badge = Badge.allBadges.first(where: { $0.id == badgeId }) {
                    NotificationManager.shared.scheduleBadgeEarnedNotification(
                        badgeName: badge.name,
                        milestone: badgeId
                    )
                }
            }
        }
        
        streak = newStreak
    }
    
    private func updateTodayStats(entries: [Entry]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let todayEntries = entries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }
        
        todayTotal = todayEntries.reduce(0) { $0 + $1.amount }
        todayEntryCount = todayEntries.count
    }
    
    private func updateActiveGoals(goals: [Goal]) {
        activeGoals = goals
            .filter { $0.isActive }
            .sorted { goal1, goal2 in
                // Sort by deadline (earliest first), then by progress
                if let days1 = goal1.daysRemaining, let days2 = goal2.daysRemaining {
                    if days1 != days2 {
                        return days1 < days2
                    }
                }
                return goal1.progressPercentage > goal2.progressPercentage
            }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            greeting = "Good morning! 👋"
        case 12..<17:
            greeting = "Good afternoon! 👋"
        case 17..<22:
            greeting = "Good evening! 👋"
        default:
            greeting = "Good night! 🌙"
        }
    }
}
