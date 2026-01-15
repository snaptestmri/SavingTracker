import Foundation

struct Category: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var emoji: String
    var isCustom: Bool
    var isDefault: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(),
         name: String,
         emoji: String,
         isCustom: Bool = false,
         isDefault: Bool = true,
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isCustom = isCustom
        self.isDefault = isDefault
        self.createdAt = createdAt
    }
    
    static let defaultCategories: [Category] = [
        Category(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
                 name: "Skipped Purchase",
                 emoji: "🛒",
                 isCustom: false,
                 isDefault: true),
        Category(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID(),
                 name: "Used Coupon",
                 emoji: "🎟️",
                 isCustom: false,
                 isDefault: true),
        Category(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003") ?? UUID(),
                 name: "Cooked at Home",
                 emoji: "🏠",
                 isCustom: false,
                 isDefault: true),
        Category(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004") ?? UUID(),
                 name: "Canceled Subscription",
                 emoji: "🚫",
                 isCustom: false,
                 isDefault: true),
        Category(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005") ?? UUID(),
                 name: "Cheaper Option",
                 emoji: "💡",
                 isCustom: false,
                 isDefault: true),
        Category(id: UUID(uuidString: "00000000-0000-0000-0000-000000000006") ?? UUID(),
                 name: "Other",
                 emoji: "➕",
                 isCustom: false,
                 isDefault: true)
    ]
}
