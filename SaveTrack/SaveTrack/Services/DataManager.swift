import Foundation
import SQLite3

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private var db: OpaquePointer?
    private let dbPath: String
    
    @Published var entries: [Entry] = []
    @Published var goals: [Goal] = []
    @Published var categories: [Category] = []
    
    private init() {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        dbPath = documentsPath.appendingPathComponent("savetrack.db").path
        
        if !fileManager.fileExists(atPath: dbPath) {
            fileManager.createFile(atPath: dbPath, contents: nil, attributes: nil)
        }
        
        openDatabase()
        createTables()
        initializeDefaultCategories()
        loadData()
    }
    
    private func openDatabase() {
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Unable to open database")
        }
    }
    
    private func createTables() {
        // Entries table
        let createEntriesTable = """
        CREATE TABLE IF NOT EXISTS entries (
            id TEXT PRIMARY KEY,
            amount TEXT NOT NULL,
            category_id TEXT NOT NULL,
            note TEXT,
            photo_data BLOB,
            timestamp REAL NOT NULL,
            created_at REAL NOT NULL,
            updated_at REAL NOT NULL
        );
        """
        
        // Goals table
        let createGoalsTable = """
        CREATE TABLE IF NOT EXISTS goals (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            target_amount TEXT NOT NULL,
            current_amount TEXT NOT NULL DEFAULT '0',
            period TEXT NOT NULL,
            start_date REAL NOT NULL,
            end_date REAL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            completed_at REAL,
            created_at REAL NOT NULL
        );
        """
        
        // Categories table
        let createCategoriesTable = """
        CREATE TABLE IF NOT EXISTS categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            emoji TEXT NOT NULL,
            is_custom INTEGER NOT NULL DEFAULT 0,
            is_default INTEGER NOT NULL DEFAULT 0,
            created_at REAL NOT NULL
        );
        """
        
        // Create indexes
        let createIndexes = """
        CREATE INDEX IF NOT EXISTS idx_entries_timestamp ON entries(timestamp);
        CREATE INDEX IF NOT EXISTS idx_entries_category ON entries(category_id);
        CREATE INDEX IF NOT EXISTS idx_goals_active ON goals(is_completed, end_date);
        """
        
        executeSQL(createEntriesTable)
        executeSQL(createGoalsTable)
        executeSQL(createCategoriesTable)
        executeSQL(createIndexes)
    }
    
    private func executeSQL(_ sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(db))
                print("Error executing SQL: \(errorMsg)")
            }
        }
        sqlite3_finalize(statement)
    }
    
    private func initializeDefaultCategories() {
        let checkQuery = "SELECT COUNT(*) FROM categories;"
        var statement: OpaquePointer?
        var count = 0
        
        if sqlite3_prepare_v2(db, checkQuery, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        
        if count == 0 {
            for category in Category.defaultCategories {
                insertCategory(category)
            }
        }
    }
    
    // MARK: - Entry Operations
    
    func saveEntry(_ entry: Entry) {
        let sql = """
        INSERT OR REPLACE INTO entries (id, amount, category_id, note, photo_data, timestamp, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, entry.id.uuidString, -1, nil)
            sqlite3_bind_text(statement, 2, entry.amount.description, -1, nil)
            sqlite3_bind_text(statement, 3, entry.categoryId.uuidString, -1, nil)
            
            if let note = entry.note {
                sqlite3_bind_text(statement, 4, note, -1, nil)
            } else {
                sqlite3_bind_null(statement, 4)
            }
            
            if let photoData = entry.photoData {
                sqlite3_bind_blob(statement, 5, photoData.withUnsafeBytes { $0.baseAddress }, Int32(photoData.count), nil)
            } else {
                sqlite3_bind_null(statement, 5)
            }
            
            sqlite3_bind_double(statement, 6, entry.timestamp.timeIntervalSince1970)
            sqlite3_bind_double(statement, 7, entry.createdAt.timeIntervalSince1970)
            sqlite3_bind_double(statement, 8, entry.updatedAt.timeIntervalSince1970)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                loadEntries()
                updateGoalsWithEntry(entry)
            }
        }
        sqlite3_finalize(statement)
    }
    
    func deleteEntry(_ entry: Entry) {
        let sql = "DELETE FROM entries WHERE id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, entry.id.uuidString, -1, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                loadEntries()
            }
        }
        sqlite3_finalize(statement)
    }
    
    func updateEntry(_ entry: Entry) {
        let sql = """
        UPDATE entries SET amount = ?, category_id = ?, note = ?, photo_data = ?, timestamp = ?, updated_at = ?
        WHERE id = ?;
        """
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, entry.amount.description, -1, nil)
            sqlite3_bind_text(statement, 2, entry.categoryId.uuidString, -1, nil)
            
            if let note = entry.note {
                sqlite3_bind_text(statement, 3, note, -1, nil)
            } else {
                sqlite3_bind_null(statement, 3)
            }
            
            if let photoData = entry.photoData {
                sqlite3_bind_blob(statement, 4, photoData.withUnsafeBytes { $0.baseAddress }, Int32(photoData.count), nil)
            } else {
                sqlite3_bind_null(statement, 4)
            }
            
            sqlite3_bind_double(statement, 5, entry.timestamp.timeIntervalSince1970)
            sqlite3_bind_double(statement, 6, Date().timeIntervalSince1970)
            sqlite3_bind_text(statement, 7, entry.id.uuidString, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                loadEntries()
            }
        }
        sqlite3_finalize(statement)
    }
    
    private func loadEntries() {
        let sql = "SELECT * FROM entries ORDER BY timestamp DESC;"
        var statement: OpaquePointer?
        var loadedEntries: [Entry] = []
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let entry = parseEntry(from: statement) {
                    loadedEntries.append(entry)
                }
            }
        }
        sqlite3_finalize(statement)
        
        DispatchQueue.main.async {
            self.entries = loadedEntries
        }
    }
    
    private func parseEntry(from statement: OpaquePointer?) -> Entry? {
        guard let statement = statement else { return nil }
        
        guard let idString = sqlite3_column_text(statement, 0),
              let id = UUID(uuidString: String(cString: idString)),
              let amountString = sqlite3_column_text(statement, 1),
              let amount = Decimal(string: String(cString: amountString)),
              let categoryIdString = sqlite3_column_text(statement, 2),
              let categoryId = UUID(uuidString: String(cString: categoryIdString)) else {
            return nil
        }
        
        let note = sqlite3_column_text(statement, 3).map { String(cString: $0) }
        
        var photoData: Data? = nil
        if let blob = sqlite3_column_blob(statement, 4) {
            let blobLength = sqlite3_column_bytes(statement, 4)
            photoData = Data(bytes: blob, count: Int(blobLength))
        }
        
        let timestamp = Date(timeIntervalSince1970: sqlite3_column_double(statement, 5))
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 6))
        let updatedAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 7))
        
        return Entry(
            id: id,
            amount: amount,
            categoryId: categoryId,
            note: note,
            photoData: photoData,
            timestamp: timestamp,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    // MARK: - Goal Operations
    
    func saveGoal(_ goal: Goal) {
        let sql = """
        INSERT OR REPLACE INTO goals (id, name, target_amount, current_amount, period, start_date, end_date, is_completed, completed_at, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, goal.id.uuidString, -1, nil)
            sqlite3_bind_text(statement, 2, goal.name, -1, nil)
            sqlite3_bind_text(statement, 3, goal.targetAmount.description, -1, nil)
            sqlite3_bind_text(statement, 4, goal.currentAmount.description, -1, nil)
            sqlite3_bind_text(statement, 5, goal.period.rawValue, -1, nil)
            sqlite3_bind_double(statement, 6, goal.startDate.timeIntervalSince1970)
            
            if let endDate = goal.endDate {
                sqlite3_bind_double(statement, 7, endDate.timeIntervalSince1970)
            } else {
                sqlite3_bind_null(statement, 7)
            }
            
            sqlite3_bind_int(statement, 8, goal.isCompleted ? 1 : 0)
            
            if let completedAt = goal.completedAt {
                sqlite3_bind_double(statement, 9, completedAt.timeIntervalSince1970)
            } else {
                sqlite3_bind_null(statement, 9)
            }
            
            sqlite3_bind_double(statement, 10, goal.createdAt.timeIntervalSince1970)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                loadGoals()
            }
        }
        sqlite3_finalize(statement)
    }
    
    func deleteGoal(_ goal: Goal) {
        let sql = "DELETE FROM goals WHERE id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, goal.id.uuidString, -1, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                loadGoals()
            }
        }
        sqlite3_finalize(statement)
    }
    
    private func loadGoals() {
        let sql = "SELECT * FROM goals ORDER BY created_at DESC;"
        var statement: OpaquePointer?
        var loadedGoals: [Goal] = []
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let goal = parseGoal(from: statement) {
                    loadedGoals.append(goal)
                }
            }
        }
        sqlite3_finalize(statement)
        
        DispatchQueue.main.async {
            self.goals = loadedGoals
        }
    }
    
    private func parseGoal(from statement: OpaquePointer?) -> Goal? {
        guard let statement = statement else { return nil }
        
        guard let idString = sqlite3_column_text(statement, 0),
              let id = UUID(uuidString: String(cString: idString)),
              let name = sqlite3_column_text(statement, 1).map({ String(cString: $0) }),
              let targetAmountString = sqlite3_column_text(statement, 2),
              let targetAmount = Decimal(string: String(cString: targetAmountString)),
              let currentAmountString = sqlite3_column_text(statement, 3),
              let currentAmount = Decimal(string: String(cString: currentAmountString)),
              let periodString = sqlite3_column_text(statement, 4),
              let period = Goal.GoalPeriod(rawValue: String(cString: periodString)) else {
            return nil
        }
        
        let startDate = Date(timeIntervalSince1970: sqlite3_column_double(statement, 5))
        let endDate = sqlite3_column_type(statement, 6) != SQLITE_NULL ? Date(timeIntervalSince1970: sqlite3_column_double(statement, 6)) : nil
        let isCompleted = sqlite3_column_int(statement, 7) == 1
        let completedAt = sqlite3_column_type(statement, 8) != SQLITE_NULL ? Date(timeIntervalSince1970: sqlite3_column_double(statement, 8)) : nil
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 9))
        
        return Goal(
            id: id,
            name: name,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            period: period,
            startDate: startDate,
            endDate: endDate,
            isCompleted: isCompleted,
            completedAt: completedAt,
            createdAt: createdAt
        )
    }
    
    private func updateGoalsWithEntry(_ entry: Entry) {
        for var goal in goals where goal.isActive {
            goal.addAmount(entry.amount)
            saveGoal(goal)
        }
    }
    
    // MARK: - Category Operations
    
    func insertCategory(_ category: Category) {
        let sql = """
        INSERT OR REPLACE INTO categories (id, name, emoji, is_custom, is_default, created_at)
        VALUES (?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, category.id.uuidString, -1, nil)
            sqlite3_bind_text(statement, 2, category.name, -1, nil)
            sqlite3_bind_text(statement, 3, category.emoji, -1, nil)
            sqlite3_bind_int(statement, 4, category.isCustom ? 1 : 0)
            sqlite3_bind_int(statement, 5, category.isDefault ? 1 : 0)
            sqlite3_bind_double(statement, 6, category.createdAt.timeIntervalSince1970)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                loadCategories()
            }
        }
        sqlite3_finalize(statement)
    }
    
    func deleteCategory(_ category: Category) {
        guard category.isCustom else { return } // Can't delete default categories
        
        let sql = "DELETE FROM categories WHERE id = ?;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, category.id.uuidString, -1, nil)
            if sqlite3_step(statement) == SQLITE_DONE {
                loadCategories()
            }
        }
        sqlite3_finalize(statement)
    }
    
    private func loadCategories() {
        let sql = "SELECT * FROM categories ORDER BY is_default DESC, name ASC;"
        var statement: OpaquePointer?
        var loadedCategories: [Category] = []
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let category = parseCategory(from: statement) {
                    loadedCategories.append(category)
                }
            }
        }
        sqlite3_finalize(statement)
        
        DispatchQueue.main.async {
            self.categories = loadedCategories
        }
    }
    
    private func parseCategory(from statement: OpaquePointer?) -> Category? {
        guard let statement = statement else { return nil }
        
        guard let idString = sqlite3_column_text(statement, 0),
              let id = UUID(uuidString: String(cString: idString)),
              let name = sqlite3_column_text(statement, 1).map({ String(cString: $0) }),
              let emoji = sqlite3_column_text(statement, 2).map({ String(cString: $0) }) else {
            return nil
        }
        
        let isCustom = sqlite3_column_int(statement, 3) == 1
        let isDefault = sqlite3_column_int(statement, 4) == 1
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 5))
        
        return Category(
            id: id,
            name: name,
            emoji: emoji,
            isCustom: isCustom,
            isDefault: isDefault,
            createdAt: createdAt
        )
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        loadEntries()
        loadGoals()
        loadCategories()
    }
    
    // MARK: - Export/Import
    
    func exportData() -> Data? {
        let exportData = ExportData(
            entries: entries,
            goals: goals,
            categories: categories,
            exportDate: Date()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        return try? encoder.encode(exportData)
    }
    
    func importData(_ data: Data) -> Bool {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let importData = try? decoder.decode(ExportData.self, from: data) else {
            return false
        }
        
        // Clear existing data
        executeSQL("DELETE FROM entries;")
        executeSQL("DELETE FROM goals;")
        executeSQL("DELETE FROM categories WHERE is_custom = 1;")
        
        // Import categories (only custom ones, defaults already exist)
        for category in importData.categories where category.isCustom {
            insertCategory(category)
        }
        
        // Import entries
        for entry in importData.entries {
            saveEntry(entry)
        }
        
        // Import goals
        for goal in importData.goals {
            saveGoal(goal)
        }
        
        loadData()
        return true
    }
    
    deinit {
        sqlite3_close(db)
    }
}

// MARK: - Export Data Structure

struct ExportData: Codable {
    let entries: [Entry]
    let goals: [Goal]
    let categories: [Category]
    let exportDate: Date
}
