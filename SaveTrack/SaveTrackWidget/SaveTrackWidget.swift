import WidgetKit
import SwiftUI

// Note: Widget extension needs to be in a separate target in Xcode
// This file shows the structure but requires proper Xcode project setup

struct SaveTrackWidget: Widget {
    let kind: String = "SaveTrackWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SaveTrackTimelineProvider()) { entry in
            SaveTrackWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SaveTrack")
        .description("View your savings streak and progress")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct SaveTrackTimelineProvider: TimelineProvider {
    typealias Entry = SaveTrackWidgetEntry
    
    func placeholder(in context: Context) -> SaveTrackWidgetEntry {
        SaveTrackWidgetEntry(
            date: Date(),
            currentStreak: 15,
            longestStreak: 23,
            todayTotal: 47.50,
            activeGoals: []
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SaveTrackWidgetEntry) -> Void) {
        let entry = loadWidgetData()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SaveTrackWidgetEntry>) -> Void) {
        let entry = loadWidgetData()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadWidgetData() -> SaveTrackWidgetEntry {
        // Load data from shared container or UserDefaults
        let dataManager = DataManager.shared
        
        let entries = dataManager.entries
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let todayEntries = entries.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
        let todayTotal = todayEntries.reduce(Decimal(0)) { $0 + $1.amount }
        
        var streak = Streak()
        streak.updateWithEntries(entries)
        
        let activeGoals = dataManager.goals.filter { $0.isActive }.prefix(2)
        
        return SaveTrackWidgetEntry(
            date: Date(),
            currentStreak: streak.currentStreak,
            longestStreak: streak.longestStreak,
            todayTotal: todayTotal,
            activeGoals: Array(activeGoals)
        )
    }
}

struct SaveTrackWidgetEntry: TimelineEntry {
    let date: Date
    let currentStreak: Int
    let longestStreak: Int
    let todayTotal: Decimal
    let activeGoals: [Goal]
}

struct SaveTrackWidgetEntryView: View {
    var entry: SaveTrackWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: SaveTrackWidgetEntry
    
    var body: some View {
        VStack(spacing: 8) {
            Text("🔥")
                .font(.title)
            Text("\(entry.currentStreak)")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            Text("day streak")
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: [Color(hex: "FF6B6B"), Color(hex: "EE5A6F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct MediumWidgetView: View {
    let entry: SaveTrackWidgetEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Streak
            VStack(alignment: .leading, spacing: 4) {
                Text("🔥 Streak")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                Text("\(entry.currentStreak) days")
                    .font(.title.bold())
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Today's Savings
            VStack(alignment: .trailing, spacing: 4) {
                Text("Today")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                Text(formatCurrency(entry.todayTotal))
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

struct LargeWidgetView: View {
    let entry: SaveTrackWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Streak
            HStack {
                Text("🔥")
                    .font(.title)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Streak")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                    Text("\(entry.currentStreak) days")
                        .font(.title.bold())
                        .foregroundColor(.white)
                }
                Spacer()
            }
            
            // Today's Savings
            HStack {
                Text("💰")
                    .font(.title)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Savings")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                    Text(formatCurrency(entry.todayTotal))
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                Spacer()
            }
            
            // Active Goals
            if !entry.activeGoals.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Active Goals")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                    
                    ForEach(entry.activeGoals.prefix(2)) { goal in
                        HStack {
                            Text(goal.name)
                                .font(.caption)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(Int(goal.progressPercentage))%")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * CGFloat(goal.progressPercentage / 100))
                            }
                            .cornerRadius(2)
                        }
                        .frame(height: 4)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

// Widget Bundle
@main
struct SaveTrackWidgetBundle: WidgetBundle {
    var body: some Widget {
        SaveTrackWidget()
    }
}
