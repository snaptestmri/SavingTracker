import SwiftUI

struct EntryTemplatesView: View {
    @StateObject private var viewModel = EntryTemplateViewModel()
    @State private var showAddTemplate = false
    @State private var templateToDelete: EntryTemplate?
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) var dismiss
    
    var onSelectTemplate: ((EntryTemplate) -> Void)?
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.templates.isEmpty {
                    EmptyTemplatesView {
                        showAddTemplate = true
                    }
                } else {
                    ForEach(viewModel.templates) { template in
                        TemplateRow(template: template, categories: DataManager.shared.categories)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let onSelect = onSelectTemplate {
                                    onSelect(template)
                                    dismiss()
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    templateToDelete = template
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .navigationTitle("Entry Templates")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddTemplate = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTemplate) {
                AddTemplateView(viewModel: viewModel)
            }
            .alert("Delete Template", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let template = templateToDelete {
                        viewModel.deleteTemplate(template)
                    }
                }
            } message: {
                if let template = templateToDelete {
                    Text("Are you sure you want to delete '\(template.name)'?")
                }
            }
        }
    }
}

struct TemplateRow: View {
    let template: EntryTemplate
    let categories: [Category]
    
    var category: Category? {
        categories.first { $0.id == template.categoryId }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.headline)
                HStack {
                    if let category = category {
                        Text(category.emoji)
                        Text(category.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                if let note = template.note {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Text(formatCurrency(template.amount))
                .font(.headline)
                .foregroundColor(Color(hex: "667eea"))
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

struct EmptyTemplatesView: View {
    let onCreateTemplate: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No templates yet")
                .font(.title2.bold())
            Text("Create templates for common entries to save time")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(action: onCreateTemplate) {
                Text("Create Template")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct AddTemplateView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: EntryTemplateViewModel
    @State private var name: String = ""
    @State private var amountText: String = ""
    @State private var selectedCategory: UUID?
    @State private var note: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Template Name", text: $name)
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    
                    Picker("Category", selection: Binding(
                        get: { selectedCategory ?? UUID() },
                        set: { selectedCategory = $0 }
                    )) {
                        ForEach(DataManager.shared.categories) { category in
                            HStack {
                                Text(category.emoji)
                                Text(category.name)
                            }
                            .tag(category.id)
                        }
                    }
                    
                    TextField("Note (Optional)", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button(action: saveTemplate) {
                        Text("Save Template")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                selectedCategory = DataManager.shared.categories.first?.id
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !amountText.isEmpty &&
        Decimal(string: amountText) != nil &&
        Decimal(string: amountText)! > 0 &&
        selectedCategory != nil
    }
    
    private func saveTemplate() {
        guard let amount = Decimal(string: amountText),
              let categoryId = selectedCategory else { return }
        
        let template = EntryTemplate(
            name: name,
            amount: amount,
            categoryId: categoryId,
            note: note.isEmpty ? nil : note
        )
        
        viewModel.saveTemplate(template)
        dismiss()
    }
}
