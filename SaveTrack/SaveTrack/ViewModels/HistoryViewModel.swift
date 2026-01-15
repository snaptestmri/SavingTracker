import Foundation
import Combine
import SwiftUI

class HistoryViewModel: ObservableObject {
    @Published var entries: [Entry] = []
    @Published var filteredEntries: [Entry] = []
    @Published var groupedEntries: [EntryGroup] = []
    @Published var searchText: String = ""
    @Published var filters: EntryFilters = EntryFilters()
    
    enum SortOption {
        case dateDesc
        case dateAsc
        case amountDesc
        case amountAsc
    }
    
    @Published var sortBy: SortOption = .dateDesc
    
    private let dataManager = DataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        dataManager.$entries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entries in
                self?.entries = entries
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)
        
        $sortBy
            .sink { [weak self] _ in
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)
    }
    
    private func applyFiltersAndSort() {
        var filtered = entries
        
        // Apply search
        if !searchText.isEmpty {
            filtered = filtered.filter { entry in
                entry.note?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        // Apply category filter
        if !filters.selectedCategories.isEmpty {
            filtered = filtered.filter { entry in
                filters.selectedCategories.contains(entry.categoryId)
            }
        }
        
        // Apply date range filter
        if let startDate = filters.startDate {
            filtered = filtered.filter { $0.timestamp >= startDate }
        }
        if let endDate = filters.endDate {
            filtered = filtered.filter { $0.timestamp <= endDate }
        }
        
        // Apply sort
        switch sortBy {
        case .dateDesc:
            filtered.sort { $0.timestamp > $1.timestamp }
        case .dateAsc:
            filtered.sort { $0.timestamp < $1.timestamp }
        case .amountDesc:
            filtered.sort { $0.amount > $1.amount }
        case .amountAsc:
            filtered.sort { $0.amount < $1.amount }
        }
        
        filteredEntries = filtered
        groupEntries()
    }
    
    private func groupEntries() {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredEntries) { entry -> String in
            if entry.isToday {
                return "TODAY"
            } else if entry.isYesterday {
                return "YESTERDAY"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM d, yyyy"
                return formatter.string(from: entry.timestamp)
            }
        }
        
        groupedEntries = grouped.map { dateString, entries in
            EntryGroup(dateString: dateString, entries: entries)
        }.sorted { group1, group2 in
            if group1.dateString == "TODAY" { return true }
            if group2.dateString == "TODAY" { return false }
            if group1.dateString == "YESTERDAY" { return true }
            if group2.dateString == "YESTERDAY" { return false }
            return group1.dateString > group2.dateString
        }
    }
    
    func deleteEntry(_ entry: Entry) {
        dataManager.deleteEntry(entry)
    }
}

struct EntryGroup: Identifiable {
    let id = UUID()
    let dateString: String
    let entries: [Entry]
}

struct EntryFilters {
    var selectedCategories: Set<UUID> = []
    var startDate: Date?
    var endDate: Date?
    
    var hasActiveFilters: Bool {
        !selectedCategories.isEmpty || startDate != nil || endDate != nil
    }
}
