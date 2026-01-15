import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var showFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search entries...", text: $viewModel.searchText)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding()
                
                // Filter/Sort Bar
                HStack {
                    Button(action: { showFilters = true }) {
                        Label("Filter", systemImage: "line.3.horizontal.decrease")
                            .font(.subheadline)
                    }
                    Spacer()
                    Menu {
                        Button("Date (Newest)") { viewModel.sortBy = .dateDesc }
                        Button("Date (Oldest)") { viewModel.sortBy = .dateAsc }
                        Button("Amount (High)") { viewModel.sortBy = .amountDesc }
                        Button("Amount (Low)") { viewModel.sortBy = .amountAsc }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Entry List
                if viewModel.groupedEntries.isEmpty {
                    EmptyHistoryView()
                } else {
                    List {
                        ForEach(viewModel.groupedEntries) { group in
                            Section(header: Text(group.dateString)
                                .font(.subheadline.bold())
                                .foregroundColor(.secondary)) {
                                ForEach(group.entries) { entry in
                                    NavigationLink(destination: EntryEditView(entry: entry)) {
                                        EntryRowView(entry: entry, categories: viewModel.categories)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            viewModel.deleteEntry(entry)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        
                                        Button {
                                            // Edit will be handled by NavigationLink
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("History")
            .sheet(isPresented: $showFilters) {
                FilterView(filters: $viewModel.filters, categories: viewModel.categories)
            }
        }
    }
}

struct EntryRowView: View {
    let entry: Entry
    let categories: [Category]
    
    var category: Category? {
        categories.first { $0.id == entry.categoryId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.formattedAmount)
                    .font(.title3.bold())
                    .foregroundColor(Color(hex: "667eea"))
                Spacer()
                Text(entry.isToday ? entry.formattedTime : entry.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let category = category {
                HStack {
                    Text(category.emoji)
                    Text(category.name)
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            }
            
            if let note = entry.note, !note.isEmpty {
                Text(note)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No entries yet")
                .font(.title2.bold())
            Text("Start tracking your savings by adding your first entry")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FilterView: View {
    @Binding var filters: EntryFilters
    let categories: [Category]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Date Range") {
                    DatePicker("Start Date", selection: Binding(
                        get: { filters.startDate ?? Date() },
                        set: { filters.startDate = $0 }
                    ), displayedComponents: .date)
                    
                    DatePicker("End Date", selection: Binding(
                        get: { filters.endDate ?? Date() },
                        set: { filters.endDate = $0 }
                    ), displayedComponents: .date)
                }
                
                Section("Categories") {
                    ForEach(categories) { category in
                        Toggle(isOn: Binding(
                            get: { filters.selectedCategories.contains(category.id) },
                            set: { isOn in
                                if isOn {
                                    filters.selectedCategories.insert(category.id)
                                } else {
                                    filters.selectedCategories.remove(category.id)
                                }
                            }
                        )) {
                            HStack {
                                Text(category.emoji)
                                Text(category.name)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Clear All Filters") {
                        filters = EntryFilters()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// Extension to add categories property to HistoryViewModel
extension HistoryViewModel {
    var categories: [Category] {
        DataManager.shared.categories
    }
}
