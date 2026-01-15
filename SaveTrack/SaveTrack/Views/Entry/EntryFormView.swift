import SwiftUI

struct EntryFormView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = EntryViewModel()
    @State private var amountText: String = ""
    @State private var selectedCategory: UUID?
    @State private var note: String = ""
    @State private var showTemplates = false
    @State private var showSaveAsTemplate = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button(action: { showTemplates = true }) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Use Template")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                Section {
                    // Amount
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount Saved *")
                            .font(.headline)
                        TextField("$0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .font(.title2.bold())
                            .onChange(of: amountText) { newValue in
                                // Format as currency
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
                        Text("Save Entry")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid)
                    
                    if isFormValid {
                        Button(action: { showSaveAsTemplate = true }) {
                            Text("Save as Template")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .navigationTitle("Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showTemplates) {
                EntryTemplatesView { template in
                    amountText = template.amount.description
                    selectedCategory = template.categoryId
                    note = template.note ?? ""
                }
            }
            .alert("Save as Template", isPresented: $showSaveAsTemplate) {
                TextField("Template Name", text: $nameBinding)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    saveAsTemplate()
                }
            } message: {
                Text("Enter a name for this template")
            }
            .onAppear {
                selectedCategory = viewModel.lastUsedCategoryId ?? viewModel.categories.first?.id
            }
        }
    }
    
    @State private var templateName: String = ""
    private var nameBinding: Binding<String> {
        Binding(
            get: { templateName },
            set: { templateName = $0 }
        )
    }
    
    private func saveAsTemplate() {
        guard let amount = Decimal(string: amountText),
              let categoryId = selectedCategory,
              !templateName.isEmpty else { return }
        
        let template = EntryTemplate(
            name: templateName,
            amount: amount,
            categoryId: categoryId,
            note: note.isEmpty ? nil : note
        )
        
        let templateViewModel = EntryTemplateViewModel()
        templateViewModel.saveTemplate(template)
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
        guard let amount = Decimal(string: amountText),
              let categoryId = selectedCategory else {
            return
        }
        
        viewModel.saveEntry(
            amount: amount,
            categoryId: categoryId,
            note: note.isEmpty ? nil : note,
            photo: nil
        )
        
        dismiss()
    }
}

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(category.emoji)
                    .font(.title2)
                Text(category.name)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color(hex: "667eea") : Color(.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : Color(.separator), lineWidth: 1)
            )
        }
    }
}
