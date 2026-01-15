import Foundation

struct EntryTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var amount: Decimal
    var categoryId: UUID
    var note: String?
    var createdAt: Date
    
    init(id: UUID = UUID(),
         name: String,
         amount: Decimal,
         categoryId: UUID,
         note: String? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.amount = amount
        self.categoryId = categoryId
        self.note = note
        self.createdAt = createdAt
    }
    
    func toEntry() -> Entry {
        Entry(
            amount: amount,
            categoryId: categoryId,
            note: note,
            timestamp: Date()
        )
    }
}
