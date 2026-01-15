import Foundation

struct Badge: Identifiable, Codable, Equatable {
    let id: Int // Milestone day count
    let name: String
    let emoji: String
    let description: String
    let earnedDate: Date?
    
    init(id: Int, name: String, emoji: String, description: String, earnedDate: Date? = nil) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.description = description
        self.earnedDate = earnedDate
    }
    
    static let allBadges: [Badge] = [
        Badge(id: 7, name: "Week Warrior", emoji: "🔥", description: "Logged entries for 7 consecutive days"),
        Badge(id: 30, name: "Monthly Master", emoji: "⭐", description: "Logged entries for 30 consecutive days"),
        Badge(id: 60, name: "Two Month Champion", emoji: "🏆", description: "Logged entries for 60 consecutive days"),
        Badge(id: 100, name: "Century Club", emoji: "💯", description: "Logged entries for 100 consecutive days"),
        Badge(id: 365, name: "Year Warrior", emoji: "👑", description: "Logged entries for 365 consecutive days")
    ]
    
    var isEarned: Bool {
        earnedDate != nil
    }
}
