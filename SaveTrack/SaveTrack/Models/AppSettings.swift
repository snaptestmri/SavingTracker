import Foundation

struct AppSettings: Codable, Equatable {
    var currency: String
    var theme: AppTheme
    var dailyReminderEnabled: Bool
    var dailyReminderTime: DateComponents
    var backupReminderFrequency: BackupFrequency
    var lastBackupDate: Date?
    var hasCompletedOnboarding: Bool
    
    enum AppTheme: String, Codable, CaseIterable {
        case light
        case dark
        case system
        
        var displayName: String {
            switch self {
            case .light: return "Light"
            case .dark: return "Dark"
            case .system: return "System"
            }
        }
    }
    
    enum BackupFrequency: String, Codable, CaseIterable {
        case never
        case weekly
        case monthly
        
        var displayName: String {
            switch self {
            case .never: return "Never"
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            }
        }
    }
    
    static let `default` = AppSettings(
        currency: "USD",
        theme: .system,
        dailyReminderEnabled: false,
        dailyReminderTime: DateComponents(hour: 20, minute: 0),
        backupReminderFrequency: .monthly,
        lastBackupDate: nil,
        hasCompletedOnboarding: false
    )
}
