import SwiftUI

struct InsightsView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var goalsViewModel = GoalsViewModel()
    let insightsEngine = InsightsEngine()
    
    @State private var insights: [Insight] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if insights.isEmpty {
                        EmptyInsightsView()
                    } else {
                        ForEach(insights) { insight in
                            InsightCard(insight: insight)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Insights")
            .onAppear {
                updateInsights()
            }
            .refreshable {
                updateInsights()
            }
        }
    }
    
    private func updateInsights() {
        insights = insightsEngine.generateInsights(
            entries: DataManager.shared.entries,
            goals: DataManager.shared.goals,
            streak: homeViewModel.streak
        )
    }
}

struct InsightCard: View {
    let insight: Insight
    
    var priorityColor: Color {
        switch insight.priority {
        case .high: return Color(hex: "667eea")
        case .medium: return Color.orange
        case .low: return Color.secondary
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(insight.emoji)
                .font(.title)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.headline)
                    .foregroundColor(priorityColor)
                
                Text(insight.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(priorityColor.opacity(0.3), lineWidth: 2)
        )
    }
}

struct EmptyInsightsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lightbulb")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No insights yet")
                .font(.title2.bold())
            Text("Keep logging entries to get personalized insights and recommendations")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}
