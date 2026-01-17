# Data Loading Flow - Where Data Goes Into Database

## 📍 Data Loading Sequence

### 1. App Launch → DataManager Initialization

**Location**: `DataManager.swift` - `private init()`

**When**: First time `DataManager.shared` is accessed (singleton pattern)

**Flow**:
```swift
private init() {
    // 1. Set up database path
    dbPath = documentsPath.appendingPathComponent("savetrack.db").path
    
    // 2. Create database file if it doesn't exist
    if !fileManager.fileExists(atPath: dbPath) {
        fileManager.createFile(atPath: dbPath, contents: nil, attributes: nil)
    }
    
    // 3. Open database connection
    openDatabase()
    
    // 4. Create tables (if they don't exist)
    createTables()
    
    // 5. Initialize default categories (if database is empty)
    initializeDefaultCategories()
    
    // 6. Load all data from database into memory
    loadData()
}
```

### 2. Create Tables

**Location**: `DataManager.swift` - `createTables()`

**What it does**:
- Creates `entries` table
- Creates `goals` table
- Creates `categories` table
- Creates indexes for performance

**Tables created**:
```sql
CREATE TABLE IF NOT EXISTS entries (...)
CREATE TABLE IF NOT EXISTS goals (...)
CREATE TABLE IF NOT EXISTS categories (...)
```

### 3. Initialize Default Categories

**Location**: `DataManager.swift` - `initializeDefaultCategories()`

**When**: Only if `SELECT COUNT(*) FROM categories` returns 0

**What it does**:
```swift
if count == 0 {
    // Insert all 6 default categories
    for category in Category.defaultCategories {
        insertCategory(category)  // ← Data inserted here
    }
}
```

**Default Categories** (from `Category.swift`):
1. 🛒 Skipped Purchase
2. 🎟️ Used Coupon
3. 🏠 Cooked at Home
4. 🚫 Canceled Subscription
5. 💡 Cheaper Option
6. ➕ Other

### 4. Insert Category Function

**Location**: `DataManager.swift` - `insertCategory(_ category: Category)`

**What it does**:
```swift
func insertCategory(_ category: Category) {
    // SQL INSERT statement
    INSERT OR REPLACE INTO categories (id, name, emoji, is_custom, is_default, created_at)
    VALUES (?, ?, ?, ?, ?, ?)
    
    // After successful insert, reload categories
    if sqlite3_step(statement) == SQLITE_DONE {
        loadCategories()  // ← Reloads from database
    }
}
```

### 5. Load Data from Database

**Location**: `DataManager.swift` - `loadData()`

**What it does**:
```swift
private func loadData() {
    loadEntries()      // Loads entries from database → @Published var entries
    loadGoals()        // Loads goals from database → @Published var goals
    loadCategories()   // Loads categories from database → @Published var categories
}
```

### 6. Load Categories Function

**Location**: `DataManager.swift` - `loadCategories()`

**What it does**:
```swift
private func loadCategories() {
    // Query database
    SELECT id, name, emoji, is_custom, is_default, created_at 
    FROM categories 
    ORDER BY is_default DESC, name ASC
    
    // Parse each row
    while sqlite3_step(statement) == SQLITE_ROW {
        if let category = parseCategory(from: statement) {
            loadedCategories.append(category)
        }
    }
    
    // Update @Published property (triggers Combine publishers)
    DispatchQueue.main.async {
        self.categories = loadedCategories
    }
}
```

## 🔄 Complete Flow Diagram

```
App Launch
    ↓
DataManager.shared (first access)
    ↓
DataManager.init()
    ↓
openDatabase() → sqlite3_open()
    ↓
createTables() → CREATE TABLE IF NOT EXISTS...
    ↓
initializeDefaultCategories()
    ↓
    Check: SELECT COUNT(*) FROM categories
    ↓
    If count == 0:
        ↓
        For each default category:
            insertCategory(category)
                ↓
                INSERT INTO categories VALUES...
                ↓
                loadCategories() ← Reloads after insert
    ↓
loadData()
    ↓
    loadEntries() → SELECT * FROM entries
    loadGoals() → SELECT * FROM goals
    loadCategories() → SELECT * FROM categories
    ↓
@Published properties updated
    ↓
ViewModels receive updates via Combine
    ↓
Views update via SwiftUI
```

## 📝 Key Functions That Write to Database

### Categories
- **`insertCategory(_ category: Category)`** - Inserts/updates a category
- **`deleteCategory(_ category: Category)`** - Deletes a category (custom only)

### Entries
- **`saveEntry(_ entry: Entry)`** - Inserts/updates an entry
- **`updateEntry(_ entry: Entry)`** - Updates an existing entry
- **`deleteEntry(_ entry: Entry)`** - Deletes an entry

### Goals
- **`saveGoal(_ goal: Goal)`** - Inserts/updates a goal
- **`deleteGoal(_ goal: Goal)`** - Deletes a goal

## 🎯 When Data is Written

1. **App First Launch**: Default categories inserted
2. **User Creates Entry**: `saveEntry()` called → INSERT INTO entries
3. **User Creates Goal**: `saveGoal()` called → INSERT INTO goals
4. **User Adds Custom Category**: `insertCategory()` called → INSERT INTO categories
5. **User Edits Entry**: `updateEntry()` called → UPDATE entries
6. **User Deletes Entry**: `deleteEntry()` called → DELETE FROM entries

## 🔍 Debugging Data Loading

### Check if categories are being inserted:
```swift
// In initializeDefaultCategories(), you should see:
print("Categories in database: \(count)")
print("Initializing default categories...")
print("Initialized \(Category.defaultCategories.count) default categories")
```

### Check if categories are being loaded:
```swift
// In loadCategories(), you should see:
print("Loaded \(loadedCategories.count) categories from database")
print("Categories updated in DataManager: \(self.categories.count)")
```

### Check database directly:
```swift
// Call debug function
DataManager.shared.debugCategories()
```

## ⚠️ Common Issues

### Issue: Categories not loading
- **Check**: Is `loadCategories()` being called?
- **Check**: Is `parseCategory()` returning nil?
- **Check**: Are there any SQL errors in console?

### Issue: Categories not inserting
- **Check**: Is `initializeDefaultCategories()` being called?
- **Check**: Is count check working correctly?
- **Check**: Are there any SQL errors during insert?

### Issue: Data not persisting
- **Check**: Is database file being created?
- **Check**: Are SQL statements executing successfully?
- **Check**: Is `sqlite3_step()` returning SQLITE_DONE?

---

**Summary**: Data is loaded into the database in `DataManager.init()` → `initializeDefaultCategories()` → `insertCategory()` for default categories, and then loaded back via `loadData()` → `loadCategories()`.
