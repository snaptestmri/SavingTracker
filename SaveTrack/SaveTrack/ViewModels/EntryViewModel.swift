import Foundation
import Combine

class EntryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var lastUsedCategoryId: UUID?
    
    private let dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadLastUsedCategory()
    }
    
    private func setupBindings() {
        dataManager.$categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] categories in
                self?.categories = categories
            }
            .store(in: &cancellables)
    }
    
    func saveEntry(amount: Decimal, categoryId: UUID, note: String?, photo: Data?) {
        let entry = Entry(
            amount: amount,
            categoryId: categoryId,
            note: note,
            photoData: photo,
            timestamp: Date()
        )
        
        dataManager.saveEntry(entry)
        saveLastUsedCategory(categoryId)
    }
    
    func updateEntry(_ entry: Entry, amount: Decimal, categoryId: UUID, note: String?, photo: Data?) {
        var updatedEntry = entry
        updatedEntry.amount = amount
        updatedEntry.categoryId = categoryId
        updatedEntry.note = note
        updatedEntry.photoData = photo
        updatedEntry.updatedAt = Date()
        
        dataManager.updateEntry(updatedEntry)
        saveLastUsedCategory(categoryId)
    }
    
    func deleteEntry(_ entry: Entry) {
        dataManager.deleteEntry(entry)
    }
    
    private func loadLastUsedCategory() {
        if let categoryIdString = UserDefaults.standard.string(forKey: "lastUsedCategoryId"),
           let categoryId = UUID(uuidString: categoryIdString) {
            lastUsedCategoryId = categoryId
        } else if let firstCategory = categories.first {
            lastUsedCategoryId = firstCategory.id
        }
    }
    
    private func saveLastUsedCategory(_ categoryId: UUID) {
        UserDefaults.standard.set(categoryId.uuidString, forKey: "lastUsedCategoryId")
        lastUsedCategoryId = categoryId
    }
}
