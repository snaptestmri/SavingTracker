import SwiftUI

struct EntryEditView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = EntryViewModel()
    let entry: Entry
    
    @State private var amountText: String
    @State private var selectedCategory: UUID
    @State private var note: String
    
    init(entry: Entry) {
        self.entry = entry
        _amountText = State(initialValue: entry.amount.description)
        _selectedCategory = State(initialValue: entry.categoryId)
        _note = State(initialValue: entry.note ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Amount
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount Saved *")
                            .font(.headline)
                        TextField("$0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .font(.title2.bold())
                            .onChange(of: amountText) { newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    amountText = filtered
                                }
                            }
                    }
                    
                    // Category
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category *")
                            .font(.headline)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(viewModel.categories) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category.id
                                ) {
                                    selectedCategory = category.id
                                }
                            }
                        }
                    }
                    
                    // Note
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note (Optional)")
                            .font(.headline)
                        TextField("What did you save on?", text: $note, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                
                Section {
                    Button(action: saveEntry) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid)
                    
                    Button(role: .destructive, action: deleteEntry) {
                        Text("Delete Entry")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        guard let amountValue = Decimal(string: amountText),
              amountValue > 0,
              selectedCategory != nil else {
            return false
        }
        return true
    }
    
    private func saveEntry() {
        guard let amount = Decimal(string: amountText) else { return }
        
        viewModel.updateEntry(
            entry,
            amount: amount,
            categoryId: selectedCategory,
            note: note.isEmpty ? nil : note,
            photo: nil
        )
        
        dismiss()
    }
    
    private func deleteEntry() {
        viewModel.deleteEntry(entry)
        dismiss()
    }
}
