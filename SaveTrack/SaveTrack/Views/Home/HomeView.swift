import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showEntryForm = false
    @State private var showBadges = false
    @State private var showInsights = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Greeting
                    HStack {
                        Text(viewModel.greeting)
                            .font(.title2.bold())
                        Spacer()
                        HStack(spacing: 12) {
                            Button(action: { showInsights = true }) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(Color(hex: "667eea"))
                            }
                            Button(action: { showBadges = true }) {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(Color(hex: "667eea"))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Streak Card with Share
                    StreakCardWithShare(streak: viewModel.streak)
                        .padding(.horizontal)
                    
                    // Longest Streak
                    if viewModel.streak.longestStreak > 0 {
                        LongestStreakCard(streak: viewModel.streak)
                            .padding(.horizontal)
                    }
                    
                    // Today's Savings
                    TodaySavingsCard(
                        amount: viewModel.todayTotal,
                        entryCount: viewModel.todayEntryCount
                    )
                    .padding(.horizontal)
                    
                    // Active Goals
                    if !viewModel.activeGoals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Active Goals")
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            ForEach(viewModel.activeGoals.prefix(3)) { goal in
                                GoalCardView(goal: goal)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                // FAB
                Button(action: { showEntryForm = true }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.primary.opacity(0.4), radius: 20, x: 0, y: 8)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 90),
                alignment: .bottomTrailing
            )
            .sheet(isPresented: $showEntryForm) {
                EntryFormView()
            }
            .sheet(isPresented: $showBadges) {
                BadgesView(streak: viewModel.streak, categories: DataManager.shared.categories)
            }
            .sheet(isPresented: $showInsights) {
                InsightsView()
            }
        }
    }
}

struct StreakCardView: View {
    let streak: Streak
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🔥 Current Streak")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            
            Text("\(streak.currentStreak) days")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            if streak.longestStreak > 0 {
                Text("Longest: \(streak.longestStreak) days")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(25)
        .background(
            LinearGradient(
                colors: [Color(hex: "FF6B6B"), Color(hex: "EE5A6F")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color(hex: "FF6B6B").opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct StreakCardWithShare: View {
    let streak: Streak
    @State private var showShare = false
    
    var body: some View {
        VStack(spacing: 12) {
            StreakCardView(streak: streak)
            
            if streak.currentStreak > 0 {
                Button(action: { showShare = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Streak")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
        .sheet(isPresented: $showShare) {
            if let image = ShareableImageGenerator.shared.generateStreakImage(streak: streak) {
                ShareSheet(activityItems: [image])
            }
        }
    }
}

struct TodaySavingsCard: View {
    let amount: Decimal
    let entryCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Savings")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(formatCurrency(amount))
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color(hex: "667eea"))
            
            Text("\(entryCount) \(entryCount == 1 ? "entry" : "entries") today")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

struct LongestStreakCard: View {
    let streak: Streak
    @State private var showDetails = false
    
    var body: some View {
        Button(action: { showDetails = true }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("🏆 Longest Streak")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        if streak.currentStreak < streak.longestStreak {
                            Text("\(streak.longestStreak - streak.currentStreak) days to beat")
                                .font(.caption)
                                .foregroundColor(Color(hex: "667eea"))
                        }
                    }
                    
                    HStack {
                        Text("\(streak.longestStreak) days")
                            .font(.title2.bold())
                        Spacer()
                        if streak.currentStreak > 0 {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Current: \(streak.currentStreak)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if streak.currentStreak < streak.longestStreak {
                                    let progress = Double(streak.currentStreak) / Double(streak.longestStreak)
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                            Rectangle()
                                                .fill(Color(hex: "667eea"))
                                                .frame(width: geometry.size.width * progress)
                                        }
                                        .cornerRadius(2)
                                    }
                                    .frame(width: 60, height: 4)
                                }
                            }
                        }
                    }
                    
                    if let startDate = streak.longestStreakStartDate,
                       let endDate = streak.longestStreakEndDate {
                        HStack {
                            Text(formatDate(startDate))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("→")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(formatDate(endDate))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(20)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(15)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetails) {
            StreakTimelineView(streak: streak)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct StreakTimelineView: View {
    let streak: Streak
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Current vs Longest Comparison
                    VStack(spacing: 16) {
                        ComparisonCard(
                            title: "Current Streak",
                            value: "\(streak.currentStreak) days",
                            emoji: "🔥"
                        )
                        
                        ComparisonCard(
                            title: "Longest Streak",
                            value: "\(streak.longestStreak) days",
                            emoji: "🏆"
                        )
                        
                        if streak.currentStreak < streak.longestStreak {
                            let daysToBeat = streak.longestStreak - streak.currentStreak
                            Text("\(daysToBeat) more days to beat your record!")
                                .font(.headline)
                                .foregroundColor(Color(hex: "667eea"))
                                .padding()
                                .background(Color(hex: "667eea").opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Date Range
                    if let startDate = streak.longestStreakStartDate,
                       let endDate = streak.longestStreakEndDate {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Longest Streak Period")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Started:")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(formatDate(startDate))
                                        .font(.subheadline.bold())
                                }
                                
                                HStack {
                                    Text("Ended:")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(formatDate(endDate))
                                        .font(.subheadline.bold())
                                }
                                
                                let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
                                HStack {
                                    Text("Duration:")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(days + 1) days")
                                        .font(.subheadline.bold())
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Streak Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct ComparisonCard: View {
    let title: String
    let value: String
    let emoji: String
    
    var body: some View {
        HStack {
            Text(emoji)
                .font(.title)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title2.bold())
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct GoalCardView: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(goal.name)
                    .font(.headline)
                Spacer()
                Text("\(goal.formattedCurrentAmount) / \(goal.formattedTargetAmount)")
                    .font(.subheadline.bold())
                    .foregroundColor(Color(hex: "667eea"))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(goal.progressPercentage / 100))
                }
                .cornerRadius(4)
            }
            .frame(height: 8)
            
            HStack {
                Text("\(Int(goal.progressPercentage))% complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let daysRemaining = goal.daysRemaining {
                    Text("• \(daysRemaining) days remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
}
