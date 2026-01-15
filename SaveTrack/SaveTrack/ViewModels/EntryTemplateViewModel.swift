import Foundation
import Combine

class EntryTemplateViewModel: ObservableObject {
    @Published var templates: [EntryTemplate] = []
    
    private let templatesKey = "entryTemplates"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTemplates()
    }
    
    func saveTemplate(_ template: EntryTemplate) {
        templates.append(template)
        saveTemplates()
    }
    
    func deleteTemplate(_ template: EntryTemplate) {
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }
    
    func updateTemplate(_ template: EntryTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            saveTemplates()
        }
    }
    
    func createEntryFromTemplate(_ template: EntryTemplate) -> Entry {
        return template.toEntry()
    }
    
    private func loadTemplates() {
        if let data = UserDefaults.standard.data(forKey: templatesKey),
           let decoded = try? JSONDecoder().decode([EntryTemplate].self, from: data) {
            templates = decoded
        }
    }
    
    private func saveTemplates() {
        if let encoded = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(encoded, forKey: templatesKey)
        }
    }
}
