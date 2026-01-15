import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showExportOptions = false
    @State private var showImportPicker = false
    @State private var showShareSheet = false
    @State private var exportData: Data?
    
    var body: some View {
        NavigationView {
            Form {
                Section("PREFERENCES") {
                    Picker("Currency", selection: $viewModel.currency) {
                        Text("USD ($)").tag("USD")
                        Text("EUR (€)").tag("EUR")
                        Text("GBP (£)").tag("GBP")
                        Text("JPY (¥)").tag("JPY")
                    }
                    
                    Picker("Theme", selection: $viewModel.theme) {
                        ForEach(AppSettings.AppTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    
                    NavigationLink {
                        ReminderSettingsView(viewModel: viewModel)
                    } label: {
                        HStack {
                            Text("Daily Reminder")
                            Spacer()
                            if viewModel.dailyReminderEnabled {
                                Text(formatTime(viewModel.dailyReminderTime))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("CATEGORIES") {
                    NavigationLink("Manage Categories") {
                        CategoryManagementView()
                    }
                }
                
                Section("DATA") {
                    Button(action: { showExportOptions = true }) {
                        HStack {
                            Text("Export Data")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: { showImportPicker = true }) {
                        HStack {
                            Text("Import Data")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Picker("Backup Reminder", selection: $viewModel.backupReminderFrequency) {
                        ForEach(AppSettings.BackupFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                }
                
                Section("ABOUT") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Export Format", isPresented: $showExportOptions) {
                Button("JSON") {
                    exportData(format: .json)
                }
                Button("CSV") {
                    exportData(format: .csv)
                }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showShareSheet) {
                if let data = exportData {
                    ShareSheet(activityItems: [data])
                }
            }
        }
    }
    
    private func exportData(format: SettingsViewModel.ExportFormat) {
        if let data = viewModel.exportData(format: format) {
            exportData = data
            showShareSheet = true
        }
    }
    
    private func formatTime(_ components: DateComponents) -> String {
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return String(format: "%02d:%02d", hour, minute)
    }
}

struct ReminderSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var reminderTime: Date = Date()
    @State private var hasRequestedPermission = false
    
    var body: some View {
        Form {
            Toggle("Enable Daily Reminder", isOn: $viewModel.dailyReminderEnabled)
                .onChange(of: viewModel.dailyReminderEnabled) { enabled in
                    if enabled && !hasRequestedPermission {
                        requestNotificationPermission()
                    }
                    updateReminderSchedule()
                }
            
            if viewModel.dailyReminderEnabled {
                DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .onChange(of: reminderTime) { newValue in
                        let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        viewModel.dailyReminderTime = components
                        updateReminderSchedule()
                    }
            }
        }
        .navigationTitle("Daily Reminder")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let calendar = Calendar.current
            var components = DateComponents()
            components.hour = viewModel.dailyReminderTime.hour ?? 20
            components.minute = viewModel.dailyReminderTime.minute ?? 0
            if let date = calendar.date(from: components) {
                reminderTime = date
            }
            checkNotificationPermission()
        }
    }
    
    private func checkNotificationPermission() {
        Task {
            let status = await NotificationManager.shared.checkNotificationStatus()
            if status == .authorized {
                hasRequestedPermission = true
            }
        }
    }
    
    private func requestNotificationPermission() {
        Task {
            let granted = await NotificationManager.shared.requestAuthorization()
            hasRequestedPermission = granted
            if granted {
                updateReminderSchedule()
            }
        }
    }
    
    private func updateReminderSchedule() {
        if viewModel.dailyReminderEnabled {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
            
            NotificationManager.shared.scheduleDailyReminder(at: components) {
                // Check if entry exists for today
                let today = Calendar.current.startOfDay(for: Date())
                return DataManager.shared.entries.contains { entry in
                    Calendar.current.isDate(entry.timestamp, inSameDayAs: today)
                }
            }
        } else {
            NotificationManager.shared.cancelDailyReminder()
        }
    }
}

// ShareSheet for exporting data
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
