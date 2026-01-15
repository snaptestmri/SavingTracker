import SwiftUI

struct CategoryManagementView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showAddCategory = false
    @State private var categoryToDelete: Category?
    @State private var showDeleteConfirmation = false
    
    var defaultCategories: [Category] {
        dataManager.categories.filter { $0.isDefault }
    }
    
    var customCategories: [Category] {
        dataManager.categories.filter { $0.isCustom }
    }
    
    var body: some View {
        List {
            Section("Default Categories") {
                ForEach(defaultCategories) { category in
                    CategoryRow(category: category, isDefault: true)
                }
            }
            
            Section("Custom Categories") {
                ForEach(customCategories) { category in
                    CategoryRow(category: category, isDefault: false)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                categoryToDelete = category
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .navigationTitle("Manage Categories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddCategory = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategoryView()
        }
        .alert("Delete Category", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let category = categoryToDelete {
                    dataManager.deleteCategory(category)
                }
            }
        } message: {
            if let category = categoryToDelete {
                Text("Are you sure you want to delete '\(category.name)'? This cannot be undone.")
            }
        }
    }
}

struct CategoryRow: View {
    let category: Category
    let isDefault: Bool
    
    var body: some View {
        HStack {
            Text(category.emoji)
                .font(.title2)
            Text(category.name)
                .font(.body)
            Spacer()
            if isDefault {
                Text("Default")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var emoji: String = "⭐"
    
    let emojiOptions = ["⭐", "💡", "🎯", "💰", "💎", "🚀", "✨", "🌟", "🎉", "🏆"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Category Name", text: $name)
                }
                
                Section("Emoji") {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(emojiOptions, id: \.self) { emojiOption in
                            Button(action: { emoji = emojiOption }) {
                                Text(emojiOption)
                                    .font(.title)
                                    .frame(width: 50, height: 50)
                                    .background(emoji == emojiOption ? Color(hex: "667eea") : Color(.secondarySystemBackground))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCategory()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCategory() {
        let category = Category(
            name: name,
            emoji: emoji,
            isCustom: true,
            isDefault: false
        )
        DataManager.shared.insertCategory(category)
        dismiss()
    }
}
