import SwiftUI

struct BadgesView: View {
    let streak: Streak
    let categories: [Category]
    
    var earnedBadges: [Badge] {
        Badge.allBadges.map { badge in
            var updatedBadge = badge
            if streak.milestoneBadges.contains(badge.id) {
                updatedBadge = Badge(
                    id: badge.id,
                    name: badge.name,
                    emoji: badge.emoji,
                    description: badge.description,
                    earnedDate: streak.badgeEarnedDates[badge.id]
                )
            }
            return updatedBadge
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Summary
                    VStack(spacing: 8) {
                        Text("\(earnedBadges.filter { $0.isEarned }.count) / \(Badge.allBadges.count)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(Color(hex: "667eea"))
                        Text("Badges Earned")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Badge Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(earnedBadges) { badge in
                            BadgeCard(badge: badge)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Badges")
        }
    }
}

struct BadgeCard: View {
    let badge: Badge
    @State private var showShare = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(badge.isEarned ? 
                          LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ) :
                          LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ))
                    .frame(width: 80, height: 80)
                
                Text(badge.emoji)
                    .font(.system(size: 40))
                    .opacity(badge.isEarned ? 1.0 : 0.3)
            }
            
            Text(badge.name)
                .font(.headline)
                .foregroundColor(badge.isEarned ? .primary : .secondary)
            
            Text(badge.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if let earnedDate = badge.earnedDate {
                Text("Earned \(formatDate(earnedDate))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                if badge.isEarned {
                    Button(action: { showShare = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                            .foregroundColor(Color(hex: "667eea"))
                    }
                }
            } else {
                Text("Not earned yet")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(badge.isEarned ? Color(hex: "667eea") : Color.clear, lineWidth: 2)
        )
        .sheet(isPresented: $showShare) {
            if let image = ShareableImageGenerator.shared.generateBadgeImage(badge: badge) {
                ShareSheet(activityItems: [image])
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
