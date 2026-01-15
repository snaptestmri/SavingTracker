import SwiftUI

@main
struct SaveTrackApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some Scene {
        WindowGroup {
            if settingsViewModel.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(hasCompletedOnboarding: $settingsViewModel.hasCompletedOnboarding)
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(1)
            
            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(2)
            
            ChartsView()
                .tabItem {
                    Label("Charts", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
    }
}
