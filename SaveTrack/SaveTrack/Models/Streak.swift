import Foundation

struct Streak: Codable, Equatable {
    var currentStreak: Int
    var longestStreak: Int
    var lastEntryDate: Date?
    var milestoneBadges: Set<Int>
    var longestStreakStartDate: Date?
    var longestStreakEndDate: Date?
    var badgeEarnedDates: [Int: Date] // Milestone day: Date earned
    
    init(currentStreak: Int = 0,
         longestStreak: Int = 0,
         lastEntryDate: Date? = nil,
         milestoneBadges: Set<Int> = [],
         longestStreakStartDate: Date? = nil,
         longestStreakEndDate: Date? = nil,
         badgeEarnedDates: [Int: Date] = [:]) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastEntryDate = lastEntryDate
        self.milestoneBadges = milestoneBadges
        self.longestStreakStartDate = longestStreakStartDate
        self.longestStreakEndDate = longestStreakEndDate
        self.badgeEarnedDates = badgeEarnedDates
    }
    
    var hasActiveStreak: Bool {
        currentStreak > 0
    }
    
    var nextMilestone: Int? {
        let milestones = [7, 30, 60, 100, 365]
        return milestones.first { $0 > currentStreak && !milestoneBadges.contains($0) }
    }
    
    mutating func updateWithEntries(_ entries: [Entry]) {
        guard !entries.isEmpty else {
            currentStreak = 0
            return
        }
        
        let sortedEntries = entries.sorted { $0.timestamp > $1.timestamp }
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        var lastEntryDate: Date?
        var streakStartDate: Date?
        var streakEndDate: Date?
        
        // Calculate current streak
        for entry in sortedEntries {
            let entryDate = calendar.startOfDay(for: entry.timestamp)
            
            if entryDate == currentDate {
                if lastEntryDate == nil {
                    streak = 1
                    lastEntryDate = entryDate
                    streakEndDate = entryDate
                    streakStartDate = entryDate
                }
            } else if let last = lastEntryDate {
                let daysDiff = calendar.dateComponents([.day], from: entryDate, to: last).day ?? 0
                if daysDiff == 1 {
                    streak += 1
                    lastEntryDate = entryDate
                    currentDate = entryDate
                    streakStartDate = entryDate
                } else {
                    break
                }
            } else {
                streak = 1
                lastEntryDate = entryDate
                currentDate = entryDate
                streakStartDate = entryDate
                streakEndDate = entryDate
            }
        }
        
        self.currentStreak = streak
        self.lastEntryDate = lastEntryDate
        
        // Calculate longest streak with date range
        var longestStreakCount = 0
        var longestStart: Date?
        var longestEnd: Date?
        var currentStreakCount = 0
        var currentStreakStart: Date?
        
        let allEntriesByDate = Dictionary(grouping: sortedEntries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        
        let sortedDates = allEntriesByDate.keys.sorted(by: >)
        
        for date in sortedDates {
            if let previousDate = longestEnd {
                let daysDiff = calendar.dateComponents([.day], from: date, to: previousDate).day ?? 0
                if daysDiff == 1 {
                    currentStreakCount += 1
                    currentStreakStart = date
                } else {
                    if currentStreakCount > longestStreakCount {
                        longestStreakCount = currentStreakCount
                        longestStart = currentStreakStart
                        longestEnd = previousDate
                    }
                    currentStreakCount = 1
                    currentStreakStart = date
                    longestEnd = date
                }
            } else {
                currentStreakCount = 1
                currentStreakStart = date
                longestEnd = date
            }
        }
        
        if currentStreakCount > longestStreakCount {
            longestStreakCount = currentStreakCount
            longestStart = currentStreakStart
            longestEnd = sortedDates.last
        }
        
        if longestStreakCount > longestStreak {
            longestStreak = longestStreakCount
            longestStreakStartDate = longestStart
            longestStreakEndDate = longestEnd
        }
        
        // Check for milestone badges
        let milestones = [7, 30, 60, 100, 365]
        for milestone in milestones {
            if streak >= milestone && !milestoneBadges.contains(milestone) {
                milestoneBadges.insert(milestone)
                badgeEarnedDates[milestone] = Date()
            }
        }
    }
}
