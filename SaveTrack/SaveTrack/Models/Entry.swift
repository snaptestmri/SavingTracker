import Foundation

struct Entry: Identifiable, Codable, Equatable {
    let id: UUID
    var amount: Decimal
    var categoryId: UUID
    var note: String?
    var photoData: Data?
    var timestamp: Date
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), 
         amount: Decimal, 
         categoryId: UUID, 
         note: String? = nil, 
         photoData: Data? = nil, 
         timestamp: Date = Date(),
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.amount = amount
        self.categoryId = categoryId
        self.note = note
        self.photoData = photoData
        self.timestamp = timestamp
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Entry {
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(timestamp)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(timestamp)
    }
}
