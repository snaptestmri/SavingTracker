import Foundation

struct Goal: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var targetAmount: Decimal
    var currentAmount: Decimal
    var period: GoalPeriod
    var startDate: Date
    var endDate: Date?
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    
    enum GoalPeriod: String, Codable, CaseIterable {
        case monthly
        case yearly
        
        var displayName: String {
            switch self {
            case .monthly: return "Monthly"
            case .yearly: return "Yearly"
            }
        }
    }
    
    init(id: UUID = UUID(),
         name: String,
         targetAmount: Decimal,
         currentAmount: Decimal = 0,
         period: GoalPeriod,
         startDate: Date = Date(),
         endDate: Date? = nil,
         isCompleted: Bool = false,
         completedAt: Date? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.period = period
        self.startDate = startDate
        self.endDate = endDate
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.createdAt = createdAt
    }
}

extension Goal {
    var progressPercentage: Double {
        guard targetAmount > 0 else { return 0 }
        let percentage = (currentAmount / targetAmount) * 100
        return min(max(Double(truncating: percentage as NSDecimalNumber), 0), 100)
    }
    
    var daysRemaining: Int? {
        guard let endDate = endDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: endDate)
        return components.day
    }
    
    var isActive: Bool {
        !isCompleted && (endDate == nil || endDate! >= Date())
    }
    
    var formattedTargetAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: targetAmount as NSDecimalNumber) ?? "$0.00"
    }
    
    var formattedCurrentAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: currentAmount as NSDecimalNumber) ?? "$0.00"
    }
    
    mutating func addAmount(_ amount: Decimal) {
        currentAmount += amount
        if currentAmount >= targetAmount && !isCompleted {
            isCompleted = true
            completedAt = Date()
        }
    }
}
