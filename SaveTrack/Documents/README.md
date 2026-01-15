# SaveTrack - iOS App

A local-first mobile application designed to help users build consistent money-saving habits through daily logging, goal tracking, streak maintenance, and data visualization.

## Overview

SaveTrack is a privacy-first iOS app that helps users track their daily money-saving actions, set savings goals, maintain streaks, and visualize their progress—all with data stored locally on the device.

## Features

### ✅ Phase 1 - Core Features (P0)

- **Daily Entry Logging** - Quick entry form with amount, category, and optional note
- **Goal Setting & Tracking** - Create monthly/yearly goals with visual progress bars
- **Streak Tracking** - Track consecutive days of logging with milestone badges
- **History & Search** - Chronological entry list with search and filtering
- **Export/Import Data** - JSON and CSV export/import for backup
- **Onboarding Flow** - Three-screen tutorial for new users

### ✅ Phase 2 - Enhanced Features (P1)

- **Edit/Delete Entries** - Full CRUD operations for entries
- **Goal Achievement Celebrations** - Confetti animations and notifications
- **Milestone Badges UI** - Visual badge display (7, 30, 60, 100, 365 days)
- **Daily Reminder Notifications** - Configurable reminders to maintain streaks
- **Charts & Analytics** - Line and pie charts with time period filtering
- **Custom Category Management** - Add, edit, and delete custom categories
- **Longest Streak Display** - Enhanced streak visualization with date ranges

### ✅ Phase 3 - Advanced Features (P2)

- **Additional Chart Types** - Bar charts, trend analysis, monthly/weekly comparisons
- **Social Sharing** - Share achievement images to social media
- **Home Screen Widgets** - WidgetKit widgets for quick access
- **Entry Templates** - Save and reuse common entries
- **Data Insights & Recommendations** - Personalized insights and recommendations
- **Enhanced Streak Timeline** - Detailed streak history and comparison

## Project Structure

```
SaveTrack/
├── App/
│   └── SaveTrackApp.swift          # Main app entry point
├── Models/
│   ├── Entry.swift                 # Entry data model
│   ├── Goal.swift                  # Goal data model
│   ├── Category.swift             # Category data model
│   ├── Streak.swift                # Streak tracking model
│   ├── AppSettings.swift          # App settings model
│   ├── Badge.swift                 # Badge model (Phase 2)
│   └── EntryTemplate.swift        # Entry template model (Phase 3)
├── ViewModels/
│   ├── HomeViewModel.swift        # Home screen logic
│   ├── EntryViewModel.swift       # Entry management logic
│   ├── GoalsViewModel.swift       # Goals management logic
│   ├── HistoryViewModel.swift     # History & filtering logic
│   ├── SettingsViewModel.swift    # Settings management logic
│   ├── ChartsViewModel.swift      # Charts & analytics logic
│   └── EntryTemplateViewModel.swift # Template management (Phase 3)
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift   # First launch tutorial
│   ├── Home/
│   │   ├── HomeView.swift         # Dashboard with streak
│   │   ├── BadgesView.swift       # Badge display (Phase 2)
│   │   └── InsightsView.swift      # Insights display (Phase 3)
│   ├── Entry/
│   │   ├── EntryFormView.swift    # Entry creation form
│   │   ├── EntryEditView.swift    # Entry editing (Phase 2)
│   │   └── EntryTemplatesView.swift # Template management (Phase 3)
│   ├── History/
│   │   └── HistoryView.swift       # Entry history & search
│   ├── Goals/
│   │   ├── GoalsView.swift        # Goals management
│   │   └── GoalCelebrationView.swift # Celebration animation (Phase 2)
│   ├── Charts/
│   │   └── ChartsView.swift       # Analytics with multiple chart types
│   └── Settings/
│       ├── SettingsView.swift     # App settings
│       └── CategoryManagementView.swift # Category management (Phase 2)
├── Services/
│   ├── DataManager.swift          # SQLite database manager
│   ├── NotificationManager.swift  # Local notifications (Phase 2)
│   ├── InsightsEngine.swift       # Insights generation (Phase 3)
│   └── ShareableImageGenerator.swift # Image generation (Phase 3)
├── SaveTrackWidget/
│   └── SaveTrackWidget.swift      # Widget extension (Phase 3)
└── SaveTrackTests/
    ├── SaveTrackIntegrationTests.swift  # Phase 1 integration tests
    ├── EntryViewModelTests.swift       # Entry tests
    ├── ModelTests.swift                # Model tests
    ├── DataManagerTests.swift          # Data manager tests
    ├── Phase2IntegrationTests.swift    # Phase 2 integration tests
    └── Phase3IntegrationTests.swift    # Phase 3 integration tests
```

## Requirements

- **Xcode**: 14.0 or later
- **iOS**: 15.0 or later (16.0+ for full chart features)
- **Swift**: 5.5 or later
- **WidgetKit**: iOS 14+ (for widgets)

## Installation

1. Open the project in Xcode
2. Select a simulator or device (iOS 15.0+)
3. Build and run (⌘R)

### Widget Setup (Optional)

To enable home screen widgets:
1. Create a Widget Extension target in Xcode
2. Add `SaveTrackWidget/SaveTrackWidget.swift` to the extension
3. Configure App Groups if needed for data sharing
4. Build and run

## Architecture

### MVVM Pattern

- **Models**: Data structures (Entry, Goal, Category, etc.)
- **Views**: SwiftUI views for UI
- **ViewModels**: Business logic and state management
- **Services**: Data persistence and utilities

### Data Persistence

- **SQLite Database**: Stored locally in app's Documents directory
- **UserDefaults**: App settings and templates
- **No Cloud Sync**: All data stays on device (privacy-first)

## Key Features Details

### Daily Entry Logging
- Quick entry form (under 30 seconds)
- Multiple entries per day
- Pre-defined categories with emoji icons
- Custom categories support
- Optional notes and photos (Phase 3)

### Goal Tracking
- Monthly or yearly goals
- Visual progress bars
- Automatic goal updates
- Multiple concurrent goals
- Goal achievement celebrations

### Streak System
- Consecutive day tracking
- Milestone badges (7, 30, 60, 100, 365 days)
- Longest streak tracking
- Streak timeline visualization
- Badge notifications

### Analytics & Charts
- Line chart: Savings over time
- Pie chart: Category breakdown
- Bar chart: Monthly comparisons
- Week-over-week comparisons
- Trend analysis with growth metrics
- Summary statistics

### Insights & Recommendations
- Personalized insights based on patterns
- Streak milestone alerts
- Goal progress recommendations
- Best day of week analysis
- Top category identification
- Consistency recommendations

### Social Sharing
- Goal achievement images
- Badge milestone images
- Streak milestone images
- Monthly summary images
- Share to all iOS destinations

### Entry Templates
- Save common entries as templates
- Quick entry from templates
- Template management
- Pre-filled forms

## Testing

### Running Tests

1. Open Test Navigator (⌘6)
2. Click play button next to "SaveTrackTests"
3. Or run specific test classes/methods

### Test Coverage

- **Phase 1**: 40+ tests covering core functionality
- **Phase 2**: 15+ tests for enhanced features
- **Phase 3**: 10+ tests for advanced features
- **Total**: 65+ tests

### Test Categories

- **Unit Tests**: Individual component testing
- **Integration Tests**: End-to-end workflow testing
- **Model Tests**: Data model validation
- **ViewModel Tests**: Business logic testing

## Data Privacy

- ✅ All data stored locally on device
- ✅ No cloud synchronization
- ✅ No user accounts required
- ✅ No analytics or tracking
- ✅ Export/Import for user control
- ✅ Optional device-level encryption

## Performance

- App launch time: < 2 seconds
- Entry save time: Instant
- Smooth scrolling: 60 FPS
- Efficient database queries
- Optimized chart rendering

## Accessibility

- ✅ VoiceOver support
- ✅ Dynamic Type support
- ✅ Reduced Motion support
- ✅ Color contrast compliance
- ✅ Semantic colors

## iOS Version Support

- **iOS 15+**: Core features
- **iOS 16+**: Full Swift Charts support
- **iOS 14+**: Widget support (with WidgetKit)

## Dependencies

- **SwiftUI**: Native UI framework
- **SQLite3**: Database (via native API)
- **Swift Charts**: iOS 16+ (with fallback for iOS 15)
- **WidgetKit**: iOS 14+ (for widgets)
- **UserNotifications**: Local notifications
- **PhotosUI**: Photo selection (Phase 3)

No external package dependencies required.

## Development Status

### ✅ Completed Phases

- **Phase 1**: Core features (P0) - ✅ Complete
- **Phase 2**: Enhanced features (P1) - ✅ Complete
- **Phase 3**: Advanced features (P2) - ✅ Complete

### Future Enhancements

- Photo attachments to entries
- Advanced search with saved filters
- Apple Watch app
- Siri Shortcuts
- Optional cloud sync
- Goal templates

## License

Copyright © 2026 SaveTrack. All rights reserved.

## Support

For issues, questions, or contributions, please refer to the project documentation.

---

**Version**: 1.0.0  
**Last Updated**: January 2026  
**Status**: Production Ready
