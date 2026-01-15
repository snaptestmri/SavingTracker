import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    func scheduleDailyReminder(at time: DateComponents, entryExists: @escaping () -> Bool) {
        // Remove existing reminder
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Log Your Savings! 💰"
        content.body = "Don't break your streak - log your savings for today."
        content.sound = .default
        content.categoryIdentifier = "DAILY_REMINDER"
        
        // Create trigger for daily notification
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "dailyReminder",
            content: content,
            trigger: trigger
        )
        
        // Add request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }
    
    func scheduleGoalAchievementNotification(goalName: String) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Goal Achieved!"
        content.body = "Congratulations! You've reached your goal: \(goalName)"
        content.sound = .default
        content.categoryIdentifier = "GOAL_ACHIEVEMENT"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "goalAchievement-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleBadgeEarnedNotification(badgeName: String, milestone: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🏆 Badge Earned!"
        content.body = "You've earned the \(badgeName) badge for \(milestone) days!"
        content.sound = .default
        content.categoryIdentifier = "BADGE_EARNED"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "badgeEarned-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func checkNotificationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
}
