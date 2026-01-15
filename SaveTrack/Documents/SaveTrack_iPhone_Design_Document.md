# SaveTrack iPhone App - Detailed Design Document

**Version:** 1.0  
**Date:** January 2026  
**Platform:** iOS (iPhone)  
**Target iOS Version:** iOS 15.0+

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Architecture Overview](#architecture-overview)
3. [Data Models](#data-models)
4. [User Interface Design](#user-interface-design)
5. [Screen Specifications](#screen-specifications)
6. [Navigation Flow](#navigation-flow)
7. [Interaction Patterns](#interaction-patterns)
8. [iOS-Specific Features](#ios-specific-features)
9. [Technical Implementation Details](#technical-implementation-details)
10. [Design System](#design-system)

---

## Executive Summary

SaveTrack is a native iOS application designed to help users build consistent money-saving habits through daily logging, goal tracking, streak maintenance, and data visualization. The app prioritizes privacy with local-only data storage, requiring no cloud infrastructure or user accounts.

### Design Philosophy

- **Speed First**: Optimize for quick entry logging (under 30 seconds)
- **Visual Motivation**: Prominent streak displays and progress indicators
- **Privacy by Design**: All data stored locally on device
- **iOS Native**: Leverage iOS design patterns and system capabilities
- **Accessibility**: Support VoiceOver, Dynamic Type, and other iOS accessibility features

---

## Architecture Overview

### Technology Stack

- **Framework**: SwiftUI (iOS 15+)
- **Language**: Swift 5.5+
- **Database**: SQLite via Core Data or SQLite.swift
- **Charts**: Swift Charts (iOS 16+) or Charts library
- **Image Handling**: PhotosUI framework
- **Localization**: SwiftUI LocalizedStringKey

### App Architecture Pattern

**MVVM (Model-View-ViewModel)** architecture recommended:

```
┌─────────────────────────────────────────┐
│           View Layer (SwiftUI)          │
│  - HomeView, HistoryView, GoalsView     │
│  - EntryFormView, ChartsView            │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│        ViewModel Layer                   │
│  - HomeViewModel, EntryViewModel         │
│  - GoalsViewModel, ChartsViewModel       │
│  - ObservableObject with @Published      │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Model Layer                      │
│  - Entry, Goal, Category, Streak         │
│  - Core Data Entities or Structs        │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│      Data Access Layer                    │
│  - DataManager, PersistenceController    │
│  - SQLite/Core Data Operations           │
└──────────────────────────────────────────┘
```

### File Structure

```
SaveTrack/
├── App/
│   ├── SaveTrackApp.swift
│   └── AppDelegate.swift
├── Models/
│   ├── Entry.swift
│   ├── Goal.swift
│   ├── Category.swift
│   ├── Streak.swift
│   └── AppSettings.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── EntryViewModel.swift
│   ├── GoalsViewModel.swift
│   ├── HistoryViewModel.swift
│   └── ChartsViewModel.swift
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   └── OnboardingPageView.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── StreakCardView.swift
│   │   └── GoalCardView.swift
│   ├── Entry/
│   │   ├── EntryFormView.swift
│   │   └── EntryDetailView.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   └── EntryRowView.swift
│   ├── Goals/
│   │   ├── GoalsView.swift
│   │   ├── GoalDetailView.swift
│   │   └── CreateGoalView.swift
│   ├── Charts/
│   │   ├── ChartsView.swift
│   │   ├── SavingsLineChartView.swift
│   │   └── CategoryPieChartView.swift
│   └── Settings/
│       ├── SettingsView.swift
│       └── CategoryManagementView.swift
├── Services/
│   ├── DataManager.swift
│   ├── StreakCalculator.swift
│   ├── NotificationManager.swift
│   └── ExportImportManager.swift
├── Utilities/
│   ├── Extensions.swift
│   ├── Constants.swift
│   └── Formatters.swift
└── Resources/
    ├── Assets.xcassets
    ├── Localizable.strings
    └── Info.plist
```

---

## Data Models

### Entry Model

```swift
struct Entry: Identifiable, Codable {
    let id: UUID
    var amount: Decimal
    var categoryId: UUID
    var note: String?
    var photoData: Data?
    var timestamp: Date
    var createdAt: Date
    var updatedAt: Date
    
    // Computed properties
    var category: Category? // Resolved from categoryId
    var formattedAmount: String
    var formattedDate: String
}
```

**Database Schema:**
- `id`: UUID (Primary Key)
- `amount`: Decimal (NOT NULL)
- `category_id`: UUID (Foreign Key)
- `note`: TEXT (Nullable)
- `photo_data`: BLOB (Nullable)
- `timestamp`: DATETIME (NOT NULL)
- `created_at`: DATETIME (NOT NULL)
- `updated_at`: DATETIME (NOT NULL)

### Goal Model

```swift
struct Goal: Identifiable, Codable {
    let id: UUID
    var name: String
    var targetAmount: Decimal
    var currentAmount: Decimal
    var period: GoalPeriod // .monthly or .yearly
    var startDate: Date
    var endDate: Date?
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    
    enum GoalPeriod: String, Codable {
        case monthly
        case yearly
    }
    
    // Computed properties
    var progressPercentage: Double
    var daysRemaining: Int?
    var isActive: Bool
}
```

**Database Schema:**
- `id`: UUID (Primary Key)
- `name`: TEXT (NOT NULL)
- `target_amount`: DECIMAL (NOT NULL)
- `current_amount`: DECIMAL (NOT NULL, default 0)
- `period`: TEXT (NOT NULL) // "monthly" or "yearly"
- `start_date`: DATETIME (NOT NULL)
- `end_date`: DATETIME (Nullable)
- `is_completed`: BOOLEAN (NOT NULL, default false)
- `completed_at`: DATETIME (Nullable)
- `created_at`: DATETIME (NOT NULL)

### Category Model

```swift
struct Category: Identifiable, Codable {
    let id: UUID
    var name: String
    var emoji: String
    var isCustom: Bool
    var isDefault: Bool
    var createdAt: Date
    
    // Pre-defined categories
    static let defaultCategories: [Category] = [
        Category(id: UUID(), name: "Skipped Purchase", emoji: "🛒", isCustom: false, isDefault: true, createdAt: Date()),
        Category(id: UUID(), name: "Used Coupon", emoji: "🎟️", isCustom: false, isDefault: true, createdAt: Date()),
        Category(id: UUID(), name: "Cooked at Home", emoji: "🏠", isCustom: false, isDefault: true, createdAt: Date()),
        Category(id: UUID(), name: "Canceled Subscription", emoji: "🚫", isCustom: false, isDefault: true, createdAt: Date()),
        Category(id: UUID(), name: "Cheaper Option", emoji: "💡", isCustom: false, isDefault: true, createdAt: Date()),
        Category(id: UUID(), name: "Other", emoji: "➕", isCustom: false, isDefault: true, createdAt: Date())
    ]
}
```

**Database Schema:**
- `id`: UUID (Primary Key)
- `name`: TEXT (NOT NULL)
- `emoji`: TEXT (NOT NULL)
- `is_custom`: BOOLEAN (NOT NULL)
- `is_default`: BOOLEAN (NOT NULL)
- `created_at`: DATETIME (NOT NULL)

### Streak Model

```swift
struct Streak: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastEntryDate: Date?
    var milestoneBadges: Set<Int> // [7, 30, 60, 100, 365]
    
    // Computed properties
    var hasActiveStreak: Bool
    var nextMilestone: Int?
}
```

**Storage:** Stored in UserDefaults or as computed property from entries

### AppSettings Model

```swift
struct AppSettings: Codable {
    var currency: String // ISO currency code (e.g., "USD")
    var theme: AppTheme // .light, .dark, .system
    var dailyReminderEnabled: Bool
    var dailyReminderTime: DateComponents // Hour and minute
    var backupReminderFrequency: BackupFrequency // .never, .weekly, .monthly
    var lastBackupDate: Date?
    var hasCompletedOnboarding: Bool
    
    enum AppTheme: String, Codable {
        case light
        case dark
        case system
    }
    
    enum BackupFrequency: String, Codable {
        case never
        case weekly
        case monthly
    }
}
```

**Storage:** UserDefaults

---

## User Interface Design

### Design System

#### Color Palette

**Primary Colors:**
- Primary Gradient: `#667eea` → `#764ba2` (Purple gradient)
- Primary: `#667eea` (Purple)
- Primary Dark: `#764ba2` (Dark Purple)

**Semantic Colors:**
- Success: `#34C759` (Green)
- Warning: `#FF9500` (Orange)
- Error: `#FF3B30` (Red)
- Streak: `#FF6B6B` → `#EE5A6F` (Red gradient)

**Neutral Colors:**
- Background: `.systemBackground` (adapts to light/dark)
- Secondary Background: `.secondarySystemBackground`
- Text Primary: `.label`
- Text Secondary: `.secondaryLabel`
- Separator: `.separator`
- Border: `.separator`

**iOS System Colors:**
Use system colors for better accessibility and theme support:
- `Color.primary`, `Color.secondary`
- `Color.systemBackground`, `Color.secondarySystemBackground`
- `Color.label`, `Color.secondaryLabel`

#### Typography

**Font System:**
- Use San Francisco (SF Pro) - iOS system font
- Support Dynamic Type for accessibility

**Type Scale:**
- Large Title: 34pt, Bold
- Title 1: 28pt, Bold
- Title 2: 22pt, Bold
- Title 3: 20pt, Bold
- Headline: 17pt, Semibold
- Body: 17pt, Regular
- Callout: 16pt, Regular
- Subheadline: 15pt, Regular
- Footnote: 13pt, Regular
- Caption 1: 12pt, Regular
- Caption 2: 11pt, Regular

**Usage:**
```swift
.font(.largeTitle.bold())      // Screen titles
.font(.title2.bold())          // Section headers
.font(.headline)               // Card titles
.font(.body)                   // Body text
.font(.subheadline)            // Secondary text
.font(.caption)                // Timestamps, labels
```

#### Spacing System

**Standard Spacing:**
- 4pt: Extra small spacing
- 8pt: Small spacing
- 12pt: Medium-small spacing
- 16pt: Medium spacing
- 20pt: Medium-large spacing
- 24pt: Large spacing
- 32pt: Extra large spacing

**Component Spacing:**
- Card padding: 20pt
- Screen padding: 20pt
- Section spacing: 24pt
- Element spacing: 16pt

#### Corner Radius

- Small: 8pt (buttons, small cards)
- Medium: 12pt (input fields, cards)
- Large: 16pt (large cards)
- Extra Large: 20pt (feature cards)

#### Shadows

```swift
// Light shadow for cards
.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)

// Medium shadow for elevated elements
.shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)

// Strong shadow for FAB
.shadow(color: Color.primary.opacity(0.4), radius: 20, x: 0, y: 8)
```

---

## Screen Specifications

### 1. Onboarding Flow

#### OnboardingView

**Purpose:** Introduce new users to SaveTrack's core concepts

**Layout:**
- Full-screen presentation
- Page-based navigation (3 pages)
- Skip button (top-right)
- Page indicators (dots at bottom)

**Page 1: Welcome**
```
┌─────────────────────────┐
│  [Skip]                 │
│                         │
│      💰                 │
│   (Large Icon)          │
│                         │
│  Welcome to SaveTrack   │
│                         │
│  Track your daily       │
│  money-saving efforts   │
│  and watch your savings │
│  grow over time.        │
│                         │
│  ● ○ ○                  │
│                         │
│  [Get Started]          │
│  [Skip]                 │
└─────────────────────────┘
```

**Page 2: Privacy**
```
┌─────────────────────────┐
│  [Skip]                 │
│                         │
│      🔒                 │
│   (Large Icon)          │
│                         │
│  Your Data Stays Local  │
│                         │
│  All your savings data  │
│  is stored securely on  │
│  your device. No cloud, │
│  no accounts needed.    │
│                         │
│  ○ ● ○                  │
│                         │
│  [Next]                 │
└─────────────────────────┘
```

**Page 3: Quick Demo**
```
┌─────────────────────────┐
│  [Skip]                 │
│                         │
│      ✏️                 │
│   (Large Icon)          │
│                         │
│  Quick & Easy Logging   │
│                         │
│  Add entries in seconds │
│  with amount, category, │
│  and optional notes.    │
│                         │
│  ○ ○ ●                  │
│                         │
│  [Get Started]          │
└─────────────────────────┘
```

**Implementation:**
```swift
struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingPageView(
                icon: "💰",
                title: "Welcome to SaveTrack",
                description: "Track your daily money-saving efforts and watch your savings grow over time."
            )
            .tag(0)
            
            OnboardingPageView(
                icon: "🔒",
                title: "Your Data Stays Local",
                description: "All your savings data is stored securely on your device. No cloud, no accounts needed."
            )
            .tag(1)
            
            OnboardingPageView(
                icon: "✏️",
                title: "Quick & Easy Logging",
                description: "Add entries in seconds with amount, category, and optional notes."
            )
            .tag(2)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
```

**Post-Onboarding:**
- Show "Create First Goal" prompt (modal or inline)
- User can skip and create goal later
- Navigate to HomeView after completion

---

### 2. Home Screen

#### HomeView

**Purpose:** Dashboard showing key metrics and quick entry access

**Layout Structure:**
```
┌─────────────────────────┐
│ Status Bar              │
├─────────────────────────┤
│                         │
│  Good morning! 👋       │
│  (Greeting)             │
│                         │
│  ┌───────────────────┐  │
│  │ 🔥 Current Streak │  │
│  │    15 days        │  │
│  │ Longest: 23 days  │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ Today's Savings   │  │
│  │    $47.50         │  │
│  │  3 entries today  │  │
│  └───────────────────┘  │
│                         │
│  Active Goals           │
│                         │
│  ┌───────────────────┐  │
│  │ Emergency Fund    │  │
│  │ $1,234 / $2,000  │  │
│  │ [Progress Bar]    │  │
│  │ 62% • 18 days left│  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ Vacation Fund     │  │
│  │ $320 / $1,500     │  │
│  │ [Progress Bar]    │  │
│  │ 21% • 75 days left│  │
│  └───────────────────┘  │
│                         │
│                         │
│         [+]             │ ← FAB
│                         │
├─────────────────────────┤
│ Home History Goals      │
│ Charts Settings         │ ← Tab Bar
└─────────────────────────┘
```

**Components:**

**1. Greeting Header**
- Time-based greeting (Good morning/afternoon/evening)
- Personalized with user's name (if set in settings)
- Font: `.title2.bold()`

**2. Streak Card**
- Gradient background (red gradient: `#FF6B6B` → `#EE5A6F`)
- Fire emoji (🔥) icon
- Current streak number (large, bold)
- Longest streak (smaller, below)
- Tap to view streak details

**3. Today's Savings Card**
- Light background (`secondarySystemBackground`)
- Large amount display
- Entry count for today
- Tap to view today's entries

**4. Active Goals Section**
- Section header: "Active Goals"
- Up to 3 most relevant goals (by deadline or progress)
- Goal cards with:
  - Goal name
  - Current amount / Target amount
  - Progress bar (gradient fill)
  - Percentage and days remaining
- Tap card to view goal details
- "View All" button if more than 3 goals

**5. Floating Action Button (FAB)**
- Position: Bottom-right, above tab bar
- Size: 60x60pt
- Gradient background (primary colors)
- Plus icon (SF Symbols: `plus`)
- Shadow for elevation
- Tap opens EntryFormView (sheet)

**Implementation:**
```swift
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showEntryForm = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Greeting
                    HStack {
                        Text(viewModel.greeting)
                            .font(.title2.bold())
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Streak Card
                    StreakCardView(streak: viewModel.streak)
                        .padding(.horizontal)
                    
                    // Today's Savings
                    TodaySavingsCard(amount: viewModel.todayTotal, 
                                    entryCount: viewModel.todayEntryCount)
                        .padding(.horizontal)
                    
                    // Active Goals
                    if !viewModel.activeGoals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Active Goals")
                                    .font(.headline)
                                Spacer()
                                if viewModel.activeGoals.count > 3 {
                                    Button("View All") {
                                        // Navigate to Goals tab
                                    }
                                    .font(.subheadline)
                                }
                            }
                            .padding(.horizontal)
                            
                            ForEach(viewModel.activeGoals.prefix(3)) { goal in
                                GoalCardView(goal: goal)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                // FAB
                Button(action: { showEntryForm = true }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.primary.opacity(0.4), 
                               radius: 20, x: 0, y: 8)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 90), // Above tab bar
                alignment: .bottomTrailing
            )
            .sheet(isPresented: $showEntryForm) {
                EntryFormView()
            }
        }
    }
}
```

---

### 3. Entry Form Screen

#### EntryFormView

**Purpose:** Quick entry creation for money-saving actions

**Layout:**
```
┌─────────────────────────┐
│ [Cancel]  Add Entry [✓] │ ← Navigation Bar
├─────────────────────────┤
│                         │
│  Amount Saved *         │
│  ┌───────────────────┐  │
│  │ $25.00            │  │ ← Currency Input
│  └───────────────────┘  │
│                         │
│  Category *             │
│  ┌──────┬──────┐        │
│  │ 🛒   │ 🏠   │        │
│  │Skip │Cook  │        │ ← Category Grid
│  └──────┴──────┘        │
│  ┌──────┬──────┐        │
│  │ 🎟️   │ 🚫   │        │
│  │Coup  │Cancel│        │
│  └──────┴──────┘        │
│  ┌──────┬──────┐        │
│  │ 💡   │ ➕   │        │
│  │Cheap │Other│        │
│  └──────┴──────┘        │
│                         │
│  Note (Optional)         │
│  ┌───────────────────┐  │
│  │ What did you      │  │ ← Text Field
│  │ save on?          │  │
│  └───────────────────┘  │
│                         │
│  Photo (Optional)        │
│  ┌───────────────────┐  │
│  │ 📷 Add Photo      │  │ ← Button
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │   Save Entry      │  │ ← Primary Button
│  └───────────────────┘  │
│                         │
└─────────────────────────┘
```

**Components:**

**1. Amount Input**
- Currency text field
- Numeric keyboard
- Real-time formatting (e.g., "$25.00")
- Validation: Must be > 0

**2. Category Selection**
- Grid layout (2 columns)
- Category buttons with emoji and name
- Selected state: filled background, white text
- Default to most recently used category
- "Add Custom" option in grid

**3. Note Field**
- Multi-line text field
- Placeholder: "What did you save on?"
- Character limit: 500 characters

**4. Photo Attachment**
- Button to add photo
- Options: Camera or Photo Library
- If photo added: Show thumbnail with delete option
- Use PhotosUI framework

**5. Save Button**
- Primary button style
- Disabled if amount or category not selected
- Shows loading state during save
- Success animation on completion

**Implementation:**
```swift
struct EntryFormView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = EntryViewModel()
    @State private var amount: String = ""
    @State private var selectedCategory: UUID?
    @State private var note: String = ""
    @State private var selectedPhoto: UIImage?
    @State private var showImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    // Amount
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount Saved *")
                            .font(.headline)
                        TextField("$0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title2.bold())
                    }
                    
                    // Category
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category *")
                            .font(.headline)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], 
                                 spacing: 12) {
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
                    
                    // Photo
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Photo (Optional)")
                            .font(.headline)
                        if let photo = selectedPhoto {
                            HStack {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                Button("Remove") {
                                    selectedPhoto = nil
                                }
                                Spacer()
                            }
                        } else {
                            Button(action: {
                                showImagePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "camera.fill")
                                    Text("Add Photo")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                Section {
                    Button(action: saveEntry) {
                        Text("Save Entry")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: imageSourceType, selectedImage: $selectedPhoto)
            }
        }
    }
    
    private var isFormValid: Bool {
        guard let amountValue = Decimal(string: amount.replacingOccurrences(of: "$", with: "")),
              amountValue > 0,
              selectedCategory != nil else {
            return false
        }
        return true
    }
    
    private func saveEntry() {
        // Save logic
        viewModel.saveEntry(
            amount: Decimal(string: amount)!,
            categoryId: selectedCategory!,
            note: note.isEmpty ? nil : note,
            photo: selectedPhoto
        )
        dismiss()
    }
}
```

---

### 4. History Screen

#### HistoryView

**Purpose:** Chronological view of all saving entries

**Layout:**
```
┌─────────────────────────┐
│ History                 │ ← Navigation Title
├─────────────────────────┤
│ ┌───────────────────┐   │
│ │ 🔍 Search...      │   │ ← Search Bar
│ └───────────────────┘   │
│                         │
│ [Filter] [Sort]         │ ← Filter/Sort Buttons
│                         │
│ TODAY                   │ ← Section Header
│ ┌───────────────────┐   │
│ │ $25.00     2:30 PM│   │
│ │ 🏠 Cooked at Home │   │ ← Entry Row
│ │ Made lunch...     │   │
│ └───────────────────┘   │
│ ┌───────────────────┐   │
│ │ $15.00    10:15 AM│   │
│ │ 🎟️ Used Coupon   │   │
│ │ 15% off groceries │   │
│ └───────────────────┘   │
│                         │
│ YESTERDAY               │
│ ┌───────────────────┐   │
│ │ $50.00    Jan 13  │   │
│ │ 🛒 Skipped Purchase│  │
│ │ Decided not to... │   │
│ └───────────────────┘   │
│                         │
│ LAST WEEK               │
│ ...                     │
│                         │
├─────────────────────────┤
│ Tab Bar                 │
└─────────────────────────┘
```

**Components:**

**1. Search Bar**
- Prominent search field at top
- Real-time search as user types
- Searches: note text, category names
- Clear button when text entered

**2. Filter/Sort Options**
- Filter button: Opens filter sheet
  - Date range picker
  - Category multi-select
  - Active filters shown as chips
- Sort options: Date (newest/oldest), Amount (high/low)

**3. Entry List**
- Grouped by date (Today, Yesterday, Date)
- Entry rows show:
  - Amount (large, bold, primary color)
  - Time/Date (small, secondary color)
  - Category badge (emoji + name)
  - Note preview (truncated)
  - Photo thumbnail (if available)
- Tap row to view/edit entry
- Swipe actions: Edit, Delete

**4. Empty State**
- When no entries: "No entries yet"
- Illustration or icon
- "Add Your First Entry" button

**Implementation:**
```swift
struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var searchText = ""
    @State private var showFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()
                
                // Filter/Sort Bar
                HStack {
                    Button(action: { showFilters = true }) {
                        Label("Filter", systemImage: "line.3.horizontal.decrease")
                    }
                    Spacer()
                    Menu {
                        Button("Date (Newest)") { viewModel.sortBy = .dateDesc }
                        Button("Date (Oldest)") { viewModel.sortBy = .dateAsc }
                        Button("Amount (High)") { viewModel.sortBy = .amountDesc }
                        Button("Amount (Low)") { viewModel.sortBy = .amountAsc }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Entry List
                if viewModel.filteredEntries.isEmpty {
                    EmptyHistoryView()
                } else {
                    List {
                        ForEach(viewModel.groupedEntries) { group in
                            Section(header: Text(group.dateString)) {
                                ForEach(group.entries) { entry in
                                    EntryRowView(entry: entry)
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                viewModel.deleteEntry(entry)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            
                                            Button {
                                                // Edit entry
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
                FilterView(filters: $viewModel.filters)
            }
            .onChange(of: searchText) { newValue in
                viewModel.searchText = newValue
            }
        }
    }
}
```

---

### 5. Goals Screen

#### GoalsView

**Purpose:** Manage and track savings goals

**Layout:**
```
┌─────────────────────────┐
│ Goals            [+]    │ ← Navigation + Add Button
├─────────────────────────┤
│                         │
│ ACTIVE GOALS            │ ← Section Header
│ ┌───────────────────┐   │
│ │ Emergency Fund    │   │
│ │ Monthly Goal      │   │
│ │                   │   │
│ │ [Progress Bar]    │   │
│ │                   │   │
│ │    $1,234         │   │
│ │ of $2,000 (62%)   │   │
│ │                   │   │
│ │ 18 days remaining │   │
│ └───────────────────┘   │
│                         │
│ COMPLETED               │
│ ┌───────────────────┐   │
│ │ Holiday Shopping  │   │
│ │ ✅ Goal Achieved! │   │
│ │ Completed Dec 2025│   │
│ └───────────────────┘   │
│                         │
├─────────────────────────┤
│ Tab Bar                 │
└─────────────────────────┘
```

**Components:**

**1. Add Goal Button**
- Navigation bar button (+)
- Opens CreateGoalView (sheet)

**2. Active Goals Section**
- Goal cards with:
  - Goal name and period
  - Progress bar (gradient)
  - Current amount / Target amount
  - Percentage complete
  - Days remaining
- Tap to view/edit goal details
- Swipe to archive/delete

**3. Completed Goals Section**
- Archived goals
- Shows completion date
- Achievement badge/icon
- Can be deleted permanently

**4. Empty State**
- "No goals yet"
- "Create Your First Goal" button

**Implementation:**
```swift
struct GoalsView: View {
    @StateObject private var viewModel = GoalsViewModel()
    @State private var showCreateGoal = false
    
    var body: some View {
        NavigationView {
            List {
                if !viewModel.activeGoals.isEmpty {
                    Section("ACTIVE GOALS") {
                        ForEach(viewModel.activeGoals) { goal in
                            GoalDetailCard(goal: goal)
                                .swipeActions {
                                    Button("Archive") {
                                        viewModel.archiveGoal(goal)
                                    }
                                }
                        }
                    }
                }
                
                if !viewModel.completedGoals.isEmpty {
                    Section("COMPLETED") {
                        ForEach(viewModel.completedGoals) { goal in
                            CompletedGoalCard(goal: goal)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateGoal = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateGoal) {
                CreateGoalView()
            }
            .overlay {
                if viewModel.activeGoals.isEmpty && viewModel.completedGoals.isEmpty {
                    EmptyGoalsView {
                        showCreateGoal = true
                    }
                }
            }
        }
    }
}
```

#### CreateGoalView

**Purpose:** Create new savings goal

**Form Fields:**
- Goal Name (text field)
- Target Amount (currency input)
- Period: Monthly / Yearly (segmented control)
- Start Date (date picker)
- End Date (optional, date picker)

**Validation:**
- Name required
- Target amount > 0
- End date must be after start date

---

### 6. Charts/Analytics Screen

#### ChartsView

**Purpose:** Visualize savings data and trends

**Layout:**
```
┌─────────────────────────┐
│ Analytics               │
├─────────────────────────┤
│ [Week] [Month] [Year]   │ ← Time Period Tabs
│                         │
│ ┌───────────────────┐   │
│ │                   │   │
│ │   Line Chart      │   │ ← Savings Over Time
│ │   (Interactive)   │   │
│ │                   │   │
│ └───────────────────┘   │
│                         │
│ ┌───────────────────┐   │
│ │                   │   │
│ │   Pie Chart       │   │ ← Category Breakdown
│ │   (Interactive)   │   │
│ │                   │   │
│ └───────────────────┘   │
│                         │
│ Summary Stats            │
│ ┌──────┬──────┐         │
│ │$1,842│$26.50│         │ ← Stats Grid
│ │Total │Avg/Day│        │
│ └──────┴──────┘         │
│ ┌──────┬──────┐         │
│ │ 142  │  🏠  │         │
│ │Entries│Top Cat│       │
│ └──────┴──────┘         │
│                         │
├─────────────────────────┤
│ Tab Bar                 │
└─────────────────────────┘
```

**Components:**

**1. Time Period Selector**
- Segmented control: Week / Month / Year
- Updates all charts and stats

**2. Savings Over Time Chart**
- Line chart (Swift Charts)
- X-axis: Dates
- Y-axis: Amount saved
- Interactive: Tap data points for details
- Shows trend line

**3. Category Breakdown Chart**
- Pie chart (Swift Charts)
- Each category as segment
- Legend with percentages
- Tap segment to highlight
- Shows category details

**4. Summary Statistics**
- Grid layout (2 columns)
- Cards showing:
  - Total Saved
  - Average Per Day
  - Total Entries
  - Top Category

**Implementation:**
```swift
import Charts

struct ChartsView: View {
    @StateObject private var viewModel = ChartsViewModel()
    @State private var selectedPeriod: TimePeriod = .month
    
    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Period Selector
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Savings Over Time Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Savings Over Time")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart(viewModel.chartData(for: selectedPeriod)) { dataPoint in
                            LineMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Amount", dataPoint.amount)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .interpolationMethod(.catmullRom)
                            
                            AreaMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Amount", dataPoint.amount)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "667eea").opacity(0.3), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                        .frame(height: 250)
                        .padding()
                        .background(Color.secondarySystemBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    // Category Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Savings by Category")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart(viewModel.categoryData(for: selectedPeriod)) { item in
                            SectorMark(
                                angle: .value("Amount", item.amount),
                                innerRadius: .ratio(0.5),
                                angularInset: 2
                            )
                            .foregroundStyle(by: .value("Category", item.categoryName))
                            .annotation(position: .overlay) {
                                Text("\(Int(item.percentage))%")
                                    .font(.caption2)
                            }
                        }
                        .frame(height: 250)
                        .padding()
                        .background(Color.secondarySystemBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    // Summary Stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Summary Stats")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], 
                                 spacing: 12) {
                            StatCard(title: "Total Saved", value: viewModel.totalSaved)
                            StatCard(title: "Avg Per Day", value: viewModel.averagePerDay)
                            StatCard(title: "Total Entries", value: "\(viewModel.totalEntries)")
                            StatCard(title: "Top Category", value: viewModel.topCategory)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
        }
    }
}
```

---

### 7. Settings Screen

#### SettingsView

**Purpose:** App configuration and data management

**Layout:**
```
┌─────────────────────────┐
│ Settings                │
├─────────────────────────┤
│                         │
│ PREFERENCES             │ ← Section
│ ┌───────────────────┐   │
│ │ Currency      USD ›│   │
│ └───────────────────┘   │
│ ┌───────────────────┐   │
│ │ Theme      System ›│   │
│ └───────────────────┘   │
│ ┌───────────────────┐   │
│ │ Daily Reminder 8PM›│   │
│ └───────────────────┘   │
│                         │
│ CATEGORIES               │
│ ┌───────────────────┐   │
│ │ Manage Categories ›│   │
│ └───────────────────┘   │
│                         │
│ DATA                     │
│ ┌───────────────────┐   │
│ │ Export Data      ›│   │
│ └───────────────────┘   │
│ ┌───────────────────┐   │
│ │ Import Data      ›│   │
│ └───────────────────┘   │
│ ┌───────────────────┐   │
│ │ Backup Reminder  ›│   │
│ └───────────────────┘   │
│                         │
│ ABOUT                    │
│ ┌───────────────────┐   │
│ │ Version     1.0.0 │   │
│ └───────────────────┘   │
│ ┌───────────────────┐   │
│ │ Privacy Policy  ›│   │
│ └───────────────────┘   │
│ ┌───────────────────┐   │
│ │ Help & Support   ›│   │
│ └───────────────────┘   │
│                         │
├─────────────────────────┤
│ Tab Bar                 │
└─────────────────────────┘
```

**Sections:**

**1. Preferences**
- Currency: Picker (USD, EUR, GBP, etc.)
- Theme: Picker (Light, Dark, System)
- Daily Reminder: Toggle + Time picker

**2. Categories**
- Manage Categories: Navigate to category management screen

**3. Data**
- Export Data: Action sheet (JSON/CSV) → Share sheet
- Import Data: Document picker → Import confirmation
- Backup Reminder: Picker (Never, Weekly, Monthly)

**4. About**
- Version: Display only
- Privacy Policy: Web view or external link
- Help & Support: Contact/support screen

**Implementation:**
```swift
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showExportOptions = false
    @State private var showImportPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("PREFERENCES") {
                    Picker("Currency", selection: $viewModel.currency) {
                        ForEach(Currency.allCases, id: \.self) { currency in
                            Text(currency.displayName).tag(currency)
                        }
                    }
                    
                    Picker("Theme", selection: $viewModel.theme) {
                        Text("Light").tag(AppTheme.light)
                        Text("Dark").tag(AppTheme.dark)
                        Text("System").tag(AppTheme.system)
                    }
                    
                    NavigationLink {
                        ReminderSettingsView()
                    } label: {
                        HStack {
                            Text("Daily Reminder")
                            Spacer()
                            if viewModel.dailyReminderEnabled {
                                Text(viewModel.dailyReminderTime.formatted(date: .omitted, time: .shortened))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("CATEGORIES") {
                    NavigationLink("Manage Categories") {
                        CategoryManagementView()
                    }
                }
                
                Section("DATA") {
                    Button(action: { showExportOptions = true }) {
                        HStack {
                            Text("Export Data")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: { showImportPicker = true }) {
                        HStack {
                            Text("Import Data")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Picker("Backup Reminder", selection: $viewModel.backupReminderFrequency) {
                        Text("Never").tag(BackupFrequency.never)
                        Text("Weekly").tag(BackupFrequency.weekly)
                        Text("Monthly").tag(BackupFrequency.monthly)
                    }
                }
                
                Section("ABOUT") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://...")!)
                    Link("Help & Support", destination: URL(string: "https://...")!)
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Export Format", isPresented: $showExportOptions) {
                Button("JSON") { viewModel.exportData(format: .json) }
                Button("CSV") { viewModel.exportData(format: .csv) }
                Button("Cancel", role: .cancel) { }
            }
            .fileImporter(
                isPresented: $showImportPicker,
                allowedContentTypes: [.json, .text],
                allowsMultipleSelection: false
            ) { result in
                // Handle import
            }
        }
    }
}
```

---

## Navigation Flow

### Main Navigation Structure

```
┌─────────────────────────────────────┐
│         Tab Bar Navigation          │
├─────────────────────────────────────┤
│  Home │ History │ Goals │ Charts │  │
│       │         │       │        │  │
│   ┌───┴───┬─────┴───┬───┴────┬───┴──┐
│   │       │         │        │      │
│ HomeView │HistoryView│GoalsView│ChartsView│
│   │       │         │        │      │
│   └───┬───┴─────┬───┴───┬────┴───┬──┘
│       │         │       │        │
│   EntryForm  EntryDetail GoalDetail
│   (Sheet)    (Sheet)    (Sheet)
└─────────────────────────────────────┘
```

### Navigation Patterns

**1. Tab-Based Navigation**
- Bottom tab bar with 5 tabs
- Persistent across app
- Badge indicators (e.g., unread notifications)

**2. Modal Presentations**
- Entry Form: Sheet (full screen on iPhone)
- Goal Creation: Sheet
- Image Picker: Sheet
- Filters: Sheet

**3. Push Navigation**
- Entry Detail: Push from History
- Goal Detail: Push from Goals
- Category Management: Push from Settings

**4. Deep Linking**
- Support URL schemes for:
  - `savetrack://entry/new` - Open entry form
  - `savetrack://goal/{id}` - Open specific goal
  - `savetrack://entry/{id}` - Open specific entry

---

## Interaction Patterns

### 1. Entry Creation Flow

```
User taps FAB
    ↓
EntryFormView presented (sheet)
    ↓
User enters amount, selects category
    ↓
(Optional) User adds note/photo
    ↓
User taps "Save Entry"
    ↓
Validation check
    ↓
Entry saved to database
    ↓
Success animation
    ↓
Sheet dismissed
    ↓
HomeView updates (streak, today's total)
```

### 2. Goal Achievement Flow

```
User adds entry
    ↓
Entry amount added to goal
    ↓
Check if goal.currentAmount >= goal.targetAmount
    ↓
If yes:
    - Mark goal as completed
    - Show celebration animation
    - Send local notification
    - Move goal to "Completed" section
    ↓
User sees achievement notification
```

### 3. Streak Calculation

```
On app launch / entry save:
    ↓
Get all entries, sorted by date
    ↓
Find most recent entry date
    ↓
Check if entry exists for today
    ↓
If yes:
    - Check if entry exists for yesterday
    - If yes: Increment streak
    - If no: Reset streak to 1
    ↓
If no entry today:
    - Check if entry exists for yesterday
    - If yes: Streak maintained (grace period?)
    - If no: Reset streak to 0
    ↓
Update streak display
    ↓
Check for milestone badges
```

### 4. Data Export Flow

```
User taps "Export Data"
    ↓
Action sheet: Choose format (JSON/CSV)
    ↓
Generate export file
    ↓
Present share sheet
    ↓
User chooses destination (Files, AirDrop, etc.)
    ↓
File saved
    ↓
Update lastBackupDate in settings
```

---

## iOS-Specific Features

### 1. Haptic Feedback

**Usage:**
- Entry saved: `.success` haptic
- Goal achieved: `.notification(.success)`
- Delete confirmation: `.warning`
- Button taps: `.light` or `.medium`

**Implementation:**
```swift
let generator = UINotificationFeedbackGenerator()
generator.notificationOccurred(.success)
```

### 2. Local Notifications

**Daily Reminder:**
- Scheduled notification at user-set time
- Only if no entry logged that day
- Tapping notification opens app to entry form

**Goal Achievement:**
- Immediate notification when goal reached
- Includes goal name and celebration message

**Implementation:**
```swift
import UserNotifications

class NotificationManager {
    func scheduleDailyReminder(at time: DateComponents) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Log Your Savings!"
        content.body = "Don't break your streak - log your savings for today."
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: time,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "dailyReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
```

### 3. Widget Support (Future)

**Home Screen Widget:**
- Small widget: Current streak
- Medium widget: Streak + Today's savings
- Large widget: Streak + Today's savings + Active goals

### 4. Shortcuts Integration

**Siri Shortcuts:**
- "Hey Siri, log savings" - Opens entry form
- "Hey Siri, how's my savings streak?" - Reads current streak
- "Hey Siri, add $25 to savings" - Quick entry creation

### 5. Spotlight Search

**Indexed Content:**
- Entry notes
- Goal names
- Category names

**Implementation:**
```swift
import CoreSpotlight

func indexEntry(_ entry: Entry) {
    let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
    attributeSet.title = "Saved $\(entry.amount)"
    attributeSet.contentDescription = entry.note
    
    let item = CSSearchableItem(
        uniqueIdentifier: entry.id.uuidString,
        domainIdentifier: "com.savetrack.entries",
        attributeSet: attributeSet
    )
    
    CSSearchableIndex.default().indexSearchableItems([item])
}
```

### 6. Dark Mode Support

**Implementation:**
- Use system colors (`.systemBackground`, `.label`)
- Use semantic colors that adapt automatically
- Test all screens in both light and dark modes
- Custom gradient colors may need dark mode variants

### 7. Dynamic Type Support

**Implementation:**
- Use relative font sizes (`.body`, `.headline`)
- Avoid fixed font sizes
- Test with largest accessibility text sizes
- Ensure layouts adapt to larger text

### 8. VoiceOver Support

**Accessibility Labels:**
```swift
Button("Save Entry") {
    // Action
}
.accessibilityLabel("Save entry")
.accessibilityHint("Saves the current entry to your savings log")

// Progress bars
ProgressView(value: progress)
    .accessibilityLabel("Goal progress")
    .accessibilityValue("\(Int(progress * 100)) percent complete")
```

---

## Technical Implementation Details

### Database Schema

**SQLite Tables:**

```sql
-- Entries Table
CREATE TABLE entries (
    id TEXT PRIMARY KEY,
    amount REAL NOT NULL,
    category_id TEXT NOT NULL,
    note TEXT,
    photo_data BLOB,
    timestamp DATETIME NOT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Goals Table
CREATE TABLE goals (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    target_amount REAL NOT NULL,
    current_amount REAL NOT NULL DEFAULT 0,
    period TEXT NOT NULL,
    start_date DATETIME NOT NULL,
    end_date DATETIME,
    is_completed INTEGER NOT NULL DEFAULT 0,
    completed_at DATETIME,
    created_at DATETIME NOT NULL
);

-- Categories Table
CREATE TABLE categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    emoji TEXT NOT NULL,
    is_custom INTEGER NOT NULL DEFAULT 0,
    is_default INTEGER NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL
);

-- Indexes
CREATE INDEX idx_entries_timestamp ON entries(timestamp);
CREATE INDEX idx_entries_category ON entries(category_id);
CREATE INDEX idx_goals_active ON goals(is_completed, end_date);
```

### Data Persistence

**Option 1: Core Data**
- Pros: iOS-native, relationship management, iCloud sync ready
- Cons: More complex setup, learning curve

**Option 2: SQLite.swift**
- Pros: Simple SQL interface, lightweight, full control
- Cons: Manual relationship management

**Recommendation:** SQLite.swift for MVP (simpler, faster development)

### Performance Optimizations

**1. Lazy Loading**
- History entries loaded in batches (pagination)
- Images loaded on-demand
- Charts data computed on-demand

**2. Caching**
- Streak calculation cached (recalculate on entry save)
- Today's total cached (update on entry save)
- Goal progress cached (update on entry save)

**3. Background Processing**
- Streak calculation in background
- Chart data preparation in background
- Photo compression in background

### Error Handling

**Network Errors:** N/A (local-only app)

**Data Errors:**
- Invalid amount input: Show validation message
- Database errors: Log and show user-friendly message
- Import errors: Show detailed error with recovery options

**User Errors:**
- Missing required fields: Highlight and show message
- Invalid date ranges: Show validation message
- Delete confirmation: Show alert before deletion

### Testing Strategy

**Unit Tests:**
- Data models
- ViewModels
- Business logic (streak calculation, goal progress)
- Data export/import

**UI Tests:**
- Entry creation flow
- Goal creation flow
- Navigation between screens
- Filter/search functionality

**Integration Tests:**
- Database operations
- Data persistence
- Export/import functionality

---

## Design System

### Component Library

#### Buttons

**Primary Button:**
```swift
Button("Save Entry") {
    // Action
}
.buttonStyle(.borderedProminent)
.controlSize(.large)
```

**Secondary Button:**
```swift
Button("Cancel") {
    // Action
}
.buttonStyle(.bordered)
```

**Icon Button:**
```swift
Button(action: { }) {
    Image(systemName: "plus")
        .font(.title2)
}
```

#### Cards

**Standard Card:**
```swift
VStack(alignment: .leading, spacing: 12) {
    // Content
}
.padding()
.background(Color.secondarySystemBackground)
.cornerRadius(16)
.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
```

**Gradient Card:**
```swift
VStack {
    // Content
}
.padding()
.background(
    LinearGradient(
        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
)
.cornerRadius(16)
.foregroundColor(.white)
```

#### Input Fields

**Text Field:**
```swift
TextField("Placeholder", text: $text)
    .textFieldStyle(.roundedBorder)
    .font(.body)
```

**Currency Field:**
```swift
TextField("$0.00", text: $amount)
    .keyboardType(.decimalPad)
    .font(.title2.bold())
    .onChange(of: amount) { newValue in
        // Format as currency
    }
```

#### Progress Bars

**Standard Progress:**
```swift
ProgressView(value: progress)
    .progressViewStyle(.linear)
    .tint(Color(hex: "667eea"))
```

**Custom Gradient Progress:**
```swift
GeometryReader { geometry in
    ZStack(alignment: .leading) {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
        
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: geometry.size.width * progress)
    }
}
.frame(height: 8)
.cornerRadius(4)
```

### Reusable Views

**StreakCardView:**
- Displays current streak with fire emoji
- Shows longest streak
- Gradient background

**GoalCardView:**
- Compact goal display
- Progress bar
- Amount and percentage

**EntryRowView:**
- List item for entry
- Amount, category, note
- Timestamp

**EmptyStateView:**
- Generic empty state
- Icon, message, action button

---

## Accessibility Considerations

### VoiceOver

- All interactive elements have labels
- Progress indicators have values
- Charts have descriptions
- Buttons have hints

### Dynamic Type

- All text uses relative sizes
- Layouts adapt to larger text
- Images scale appropriately

### Color Contrast

- Minimum 4.5:1 for normal text
- Minimum 3:1 for large text
- Don't rely solely on color for information

### Reduced Motion

- Respect `UIAccessibility.isReduceMotionEnabled`
- Provide alternative animations
- Skip confetti/celebrations if motion reduced

---

## Security & Privacy

### Data Storage

- All data stored locally in app sandbox
- SQLite database encrypted at rest (iOS default)
- Photos stored in app's Documents directory
- No data transmitted to external servers

### Permissions

- Photo Library: Request when user adds photo
- Camera: Request when user takes photo
- Notifications: Request for daily reminders

### Privacy Policy

- Clear statement: "All data stored locally"
- No analytics or tracking
- No third-party SDKs that collect data
- User controls all data through export/import

---

## Launch Checklist

### Pre-Launch

- [ ] All P0 user stories implemented
- [ ] Core features tested
- [ ] Dark mode tested
- [ ] Accessibility tested
- [ ] Performance optimized
- [ ] Error handling implemented
- [ ] Privacy policy written
- [ ] App Store assets prepared
- [ ] App Store description written
- [ ] Screenshots captured

### Post-Launch

- [ ] Monitor crash reports
- [ ] Collect user feedback
- [ ] Track success metrics
- [ ] Plan P1 feature releases

---

## Future Enhancements

### Phase 2 (P1 Features)

- Milestone badges
- Goal achievement celebrations
- Enhanced charts (bar charts, trends)
- Category management UI
- Search functionality

### Phase 3 (P2 Features)

- Photo attachments
- Longest streak display
- Additional chart types
- Social sharing (achievements)
- Widget support

### Phase 4 (Post-MVP)

- Apple Watch app
- Home screen widgets
- Siri Shortcuts
- Optional cloud sync
- Goal templates

---

## Conclusion

This design document provides a comprehensive blueprint for building the SaveTrack iPhone app. The design prioritizes:

1. **Speed**: Quick entry logging in under 30 seconds
2. **Motivation**: Visual streak and progress indicators
3. **Privacy**: Local-only data storage
4. **iOS Native**: Leveraging SwiftUI and iOS design patterns
5. **Accessibility**: Full support for iOS accessibility features

The app architecture follows MVVM pattern with SwiftUI, ensuring maintainability and testability. All core features from the PRD and user stories are addressed with detailed screen specifications and implementation guidance.

---

**Document Version:** 1.0  
**Last Updated:** January 2026  
**Author:** Design Team  
**Status:** Ready for Development
