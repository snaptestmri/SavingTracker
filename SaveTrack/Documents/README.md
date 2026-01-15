# SaveTrack - iOS App

A local-first mobile application designed to help users build consistent money-saving habits through daily logging, goal tracking, streak maintenance, and data visualization.

## Phase 1 Implementation Status

✅ **Completed Features:**

### Core Features (P0)
- ✅ Daily Entry Logging (US-003, US-004)
- ✅ Goal Setting & Tracking (US-007, US-008)
- ✅ Streak Tracking (US-011)
- ✅ History & Search (US-018)
- ✅ Export/Import Data (US-021, US-022)
- ✅ Onboarding Flow (US-001)

### Technical Implementation
- ✅ Data Models (Entry, Goal, Category, Streak, AppSettings)
- ✅ SQLite Database with DataManager
- ✅ MVVM Architecture with SwiftUI
- ✅ ViewModels for all screens
- ✅ Complete UI implementation
- ✅ Integration Tests

## Project Structure

```
SaveTrack/
├── App/
│   └── SaveTrackApp.swift          # Main app entry point
├── Models/
│   ├── Entry.swift                  # Entry data model
│   ├── Goal.swift                  # Goal data model
│   ├── Category.swift              # Category data model
│   ├── Streak.swift                # Streak tracking model
│   └── AppSettings.swift          # App settings model
├── ViewModels/
│   ├── HomeViewModel.swift        # Home screen logic
│   ├── EntryViewModel.swift       # Entry management logic
│   ├── GoalsViewModel.swift       # Goals management logic
│   ├── HistoryViewModel.swift     # History & filtering logic
│   └── SettingsViewModel.swift    # Settings management logic
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift   # First launch tutorial
│   ├── Home/
│   │   └── HomeView.swift         # Dashboard with streak
│   ├── Entry/
│   │   └── EntryFormView.swift    # Entry creation form
│   ├── History/
│   │   └── HistoryView.swift      # Entry history & search
│   ├── Goals/
│   │   └── GoalsView.swift        # Goals management
│   ├── Charts/
│   │   └── ChartsView.swift       # Analytics (placeholder)
│   └── Settings/
│       └── SettingsView.swift     # App settings
├── Services/
│   └── DataManager.swift         # SQLite database manager
└── SaveTrackTests/
    ├── SaveTrackIntegrationTests.swift  # Integration tests
    ├── EntryViewModelTests.swift       # Entry tests
    ├── ModelTests.swift                # Model tests
    └── DataManagerTests.swift          # Data manager tests
```

## Running the App

### Requirements
- Xcode 14.0 or later
- iOS 15.0 or later
- Swift 5.5 or later

### Setup
1. Open the project in Xcode
2. Select a simulator or device
3. Build and run (⌘R)

### Running Tests
1. Open Test Navigator (⌘6)
2. Click the play button next to "SaveTrackTests"
3. Or run specific test classes/methods

## Testing

### Integration Tests
Comprehensive integration tests cover:
- Entry creation, update, deletion
- Goal creation and progress tracking
- Streak calculation
- Category management
- Export/Import functionality
- ViewModel logic

### Test Coverage
- ✅ Entry operations
- ✅ Goal operations
- ✅ Streak calculations
- ✅ Data persistence
- ✅ Export/Import
- ✅ ViewModel logic

## Features

### Daily Entry Logging
- Quick entry form with amount, category, and optional note
- Multiple entries per day supported
- Pre-defined categories with emoji icons
- Automatic timestamp tracking

### Goal Tracking
- Create monthly or yearly savings goals
- Visual progress bars
- Automatic goal updates when entries are added
- Multiple concurrent goals supported
- Goal completion tracking

### Streak Tracking
- Tracks consecutive days of logging
- Displays current streak and longest streak
- Milestone badge system (7, 30, 60, 100, 365 days)

### History & Search
- Chronological list of all entries
- Search by note text
- Filter by category and date range
- Sort by date or amount

### Data Management
- Export data to JSON or CSV
- Import data from backup files
- All data stored locally (privacy-first)

## Architecture

### MVVM Pattern
- **Models**: Data structures (Entry, Goal, Category, etc.)
- **Views**: SwiftUI views for UI
- **ViewModels**: Business logic and state management
- **Services**: Data persistence (DataManager)

### Data Persistence
- SQLite database stored locally
- No cloud synchronization
- Export/Import for backup and migration

## Next Steps (Phase 2)

- [ ] Charts & Analytics (US-015, US-016)
- [ ] Edit/Delete entries (US-005)
- [ ] Goal achievement celebrations (US-009)
- [ ] Milestone badges UI (US-012)
- [ ] Daily reminder notifications (US-013)
- [ ] Custom category management (US-024)

## License

Copyright © 2026 SaveTrack. All rights reserved.
