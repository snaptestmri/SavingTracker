# SaveTrack Phase 2 - Implementation Plan

## Overview

Phase 2 focuses on implementing **P1 (High Priority)** features that enhance user experience, motivation, and data insights. These features are important for launch but can be delayed if necessary.

## Phase 2 Features (P1 Priority)

### 1. Edit/Delete Entries (US-005) ⚠️ Partially Implemented
**Status**: Delete is implemented, Edit needs UI

**Requirements:**
- ✅ Delete entries (already working via swipe actions)
- ⚠️ Edit entry UI and functionality
- Tap on entry in history to open edit screen
- Can modify amount, category, and note
- Changes reflect immediately in totals and charts

**Implementation Tasks:**
- [ ] Create `EntryEditView` (similar to EntryFormView but pre-filled)
- [ ] Add navigation from HistoryView to EntryEditView
- [ ] Update EntryViewModel with edit functionality
- [ ] Add confirmation dialog for delete
- [ ] Test edit/delete workflows

---

### 2. Goal Achievement Celebrations (US-009) 🎉
**Status**: Logic exists, UI needed

**Requirements:**
- ✅ Goal completion detection (already working)
- ⚠️ Celebration animation/screen when goal is reached
- In-app notification when goal is achieved
- Goal marked as completed and moved to archive
- Option to create a new goal immediately

**Implementation Tasks:**
- [ ] Create `GoalCelebrationView` with confetti animation
- [ ] Add celebration trigger in GoalsViewModel
- [ ] Implement local notification for goal achievement
- [ ] Add "Create New Goal" button in celebration view
- [ ] Test celebration flow

---

### 3. Milestone Badges UI (US-012) 🏆
**Status**: Backend tracking exists, UI needed

**Requirements:**
- ✅ Badge tracking at milestones (7, 30, 60, 100, 365 days) - already in Streak model
- ⚠️ Badge display UI
- Notification when badge is earned
- Badges displayed in user profile or achievements section
- Each badge has unique icon and description

**Implementation Tasks:**
- [ ] Create `Badge` model with icon and description
- [ ] Create `BadgesView` to display earned badges
- [ ] Add badge notification when milestone reached
- [ ] Add badges section to Home or Settings screen
- [ ] Design badge icons/emojis for each milestone
- [ ] Test badge earning and display

---

### 4. Daily Reminder Notifications (US-013) 🔔
**Status**: Settings exist, notifications not implemented

**Requirements:**
- ✅ Settings UI for reminder (already exists)
- ⚠️ Local notification implementation
- Optional notification enabled in settings
- User can set preferred notification time
- Notification only sent if no entry logged that day
- Tapping notification opens app to entry form

**Implementation Tasks:**
- [ ] Create `NotificationManager` service
- [ ] Implement UNUserNotifications framework
- [ ] Schedule daily notifications at user-set time
- [ ] Check if entry exists before sending notification
- [ ] Handle notification tap to open entry form
- [ ] Request notification permissions
- [ ] Test notification scheduling and delivery

---

### 5. Charts & Analytics (US-015, US-016) 📊
**Status**: Placeholder view exists

**Requirements:**
- Line chart showing savings over time
- Weekly, monthly, and yearly view options
- Interactive chart with data point values on tap
- Pie chart displaying breakdown of savings by category
- Legend with category names and amounts
- Filter by time period (this month, this year, all time)
- Tap segment to see category details

**Implementation Tasks:**
- [ ] Create `ChartsViewModel` for data preparation
- [ ] Implement line chart using Swift Charts (iOS 16+)
- [ ] Implement pie chart for category breakdown
- [ ] Add time period selector (Week/Month/Year)
- [ ] Add interactive chart features (tap for details)
- [ ] Create summary statistics cards
- [ ] Test chart rendering with various data sets
- [ ] Handle empty state (no data)

---

### 6. Custom Category Management (US-024) 🏷️
**Status**: Backend exists, UI needed

**Requirements:**
- ✅ Custom category creation in DataManager
- ⚠️ Category management UI
- "Manage Categories" option in Settings
- List of all categories (pre-defined and custom)
- Add new category with name input
- Edit or delete custom categories
- Cannot delete pre-defined categories

**Implementation Tasks:**
- [ ] Create `CategoryManagementView`
- [ ] Add navigation from Settings
- [ ] Implement add category form
- [ ] Implement edit category functionality
- [ ] Implement delete category (with confirmation)
- [ ] Show which categories are default vs custom
- [ ] Prevent deletion of default categories
- [ ] Test category CRUD operations

---

## Additional Enhancements

### 7. View Longest Streak (US-014) - P2 but can be P1
**Status**: Data exists, display needed

**Requirements:**
- ✅ Longest streak tracking (already in Streak model)
- ⚠️ Display longest streak on home screen
- Updates automatically when current streak exceeds previous record
- Include date range of when longest streak occurred

**Implementation Tasks:**
- [ ] Update HomeView to show longest streak
- [ ] Add date range tracking to Streak model
- [ ] Display longest streak with date range
- [ ] Test longest streak updates

---

## Technical Requirements

### New Dependencies
- **Swift Charts** (iOS 16+) - For charts and analytics
- **UserNotifications** framework - For daily reminders

### New Services
- `NotificationManager.swift` - Handle local notifications
- `ChartsViewModel.swift` - Prepare chart data

### New Views
- `EntryEditView.swift` - Edit existing entries
- `GoalCelebrationView.swift` - Celebration animation
- `BadgesView.swift` - Display earned badges
- `CategoryManagementView.swift` - Manage categories
- Enhanced `ChartsView.swift` - Full analytics implementation

### Updated Models
- `Streak.swift` - Add date range tracking for longest streak
- `Badge.swift` - New model for milestone badges

## Implementation Priority Order

1. **Edit/Delete Entries** (US-005) - High user value, quick win
2. **Daily Reminder Notifications** (US-013) - Improves habit formation
3. **Charts & Analytics** (US-015, US-016) - High user value, visual insights
4. **Goal Achievement Celebrations** (US-009) - Motivation boost
5. **Milestone Badges UI** (US-012) - Gamification enhancement
6. **Custom Category Management** (US-024) - User customization

## Estimated Effort

| Feature | Complexity | Estimated Time |
|---------|-----------|----------------|
| Edit/Delete Entries | Low | 2-3 hours |
| Daily Reminders | Medium | 4-6 hours |
| Charts & Analytics | High | 8-12 hours |
| Goal Celebrations | Medium | 4-6 hours |
| Badges UI | Medium | 4-6 hours |
| Category Management | Low | 3-4 hours |
| **Total** | | **25-37 hours** |

## Testing Requirements

### Unit Tests
- [ ] NotificationManager tests
- [ ] ChartsViewModel tests
- [ ] Badge model tests
- [ ] Category management tests

### Integration Tests
- [ ] Edit entry workflow
- [ ] Goal celebration trigger
- [ ] Badge earning flow
- [ ] Notification scheduling
- [ ] Chart data accuracy
- [ ] Category CRUD operations

### UI Tests
- [ ] Edit entry flow
- [ ] Celebration animation
- [ ] Badge display
- [ ] Notification interaction
- [ ] Chart interactions
- [ ] Category management flow

## Success Criteria

Phase 2 is complete when:
- ✅ All 6 P1 features are implemented
- ✅ All features have unit and integration tests
- ✅ UI is polished and follows design system
- ✅ No regressions in Phase 1 features
- ✅ Performance is maintained (< 2s launch time)
- ✅ All tests pass

## Notes

- Some features (like delete) are already partially implemented
- Charts require iOS 16+ for Swift Charts, may need fallback for iOS 15
- Notifications require user permission, handle gracefully if denied
- Badge icons should be consistent with app design language
- Celebration animations should respect reduced motion accessibility

---

**Phase 2 Status**: 🟡 Ready to Start  
**Estimated Completion**: 2-3 weeks (depending on team size)
