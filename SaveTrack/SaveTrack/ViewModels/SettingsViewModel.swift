import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings = AppSettings.default
    
    private let settingsKey = "appSettings"
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    var currency: String {
        get { settings.currency }
        set {
            settings.currency = newValue
            saveSettings()
        }
    }
    
    var theme: AppSettings.AppTheme {
        get { settings.theme }
        set {
            settings.theme = newValue
            saveSettings()
        }
    }
    
    var dailyReminderEnabled: Bool {
        get { settings.dailyReminderEnabled }
        set {
            settings.dailyReminderEnabled = newValue
            saveSettings()
        }
    }
    
    var dailyReminderTime: DateComponents {
        get { settings.dailyReminderTime }
        set {
            settings.dailyReminderTime = newValue
            saveSettings()
        }
    }
    
    var backupReminderFrequency: AppSettings.BackupFrequency {
        get { settings.backupReminderFrequency }
        set {
            settings.backupReminderFrequency = newValue
            saveSettings()
        }
    }
    
    var hasCompletedOnboarding: Bool {
        get { settings.hasCompletedOnboarding }
        set {
            settings.hasCompletedOnboarding = newValue
            saveSettings()
        }
    }
    
    func exportData(format: ExportFormat) -> Data? {
        let data = DataManager.shared.exportData()
        
        if format == .csv {
            return convertToCSV(data)
        }
        
        return data
    }
    
    func importData(_ data: Data) -> Bool {
        return DataManager.shared.importData(data)
    }
    
    private func convertToCSV(_ jsonData: Data?) -> Data? {
        guard let jsonData = jsonData,
              let exportData = try? JSONDecoder().decode(ExportData.self, from: jsonData) else {
            return nil
        }
        
        var csv = "Date,Amount,Category,Note\n"
        
        for entry in exportData.entries {
            let date = DateFormatter().string(from: entry.timestamp)
            let amount = entry.amount.description
            let category = exportData.categories.first { $0.id == entry.categoryId }?.name ?? "Unknown"
            let note = entry.note?.replacingOccurrences(of: ",", with: ";") ?? ""
            
            csv += "\(date),\(amount),\(category),\(note)\n"
        }
        
        return csv.data(using: .utf8)
    }
    
    enum ExportFormat {
        case json
        case csv
    }
}
