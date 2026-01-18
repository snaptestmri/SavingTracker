SaveTrack User Stories
 
Introduction
This document contains user stories for the SaveTrack mobile application. Each story follows the format: 'As a [user type], I want to [action], so that [benefit].' Stories are organized by feature area and include acceptance criteria and priority levels.

Priority Levels
P0 (Critical): Must have for MVP launch
P1 (High): Important for launch, can be delayed if necessary
P2 (Medium): Nice to have, post-MVP

Onboarding & First Use
US-001: First Launch Tutorial
Priority: P0
User Story:
As a new user, I want to see a brief tutorial when I first open the app, so that I understand what the app does and how to use it.
Acceptance Criteria:
Tutorial appears only on first app launch
Three screens explaining: app concept, privacy benefits, how to add entries
User can skip tutorial at any time
After tutorial, user is prompted to set first goal


US-002: Set First Goal
Priority: P1
User Story:
As a new user, I want to be guided to set my first savings goal, so that I have a target to work toward from the beginning.
Acceptance Criteria:
Prompt appears after tutorial or can be skipped
Simple form with goal amount and time period (monthly/yearly)
User can skip and set goal later


Daily Entry Logging
US-003: Quick Entry Creation
Priority: P0
User Story:
As a user, I want to quickly log a money-saving action, so that I can capture my savings in under 30 seconds.
Acceptance Criteria:
Large, prominent 'Add Entry' button on home screen
Entry form with: amount (required), category dropdown, optional note
Timestamp automatically captured
Entry saves instantly when submitted
Success confirmation shown briefly


US-004: Category Selection
Priority: P0
User Story:
As a user, I want to categorize my savings entries, so that I can see which types of actions save me the most money.
Acceptance Criteria:
Dropdown shows pre-defined categories: Skipped Purchase, Used Coupon/Discount, Cooked at Home, Canceled Subscription, Chose Cheaper Alternative, Other
Category defaults to most recently used
Option to add custom category from dropdown


US-005: Edit Past Entry
Priority: P1
User Story:
As a user, I want to edit or delete a past entry, so that I can correct mistakes or remove accidental entries.
Acceptance Criteria:
Tap on any entry in history to open edit screen
Can modify amount, category, and note
Delete option with confirmation dialog
Changes reflect immediately in totals and charts


US-006: Add Photo to Entry
Priority: P2
User Story:
As a user, I want to attach a photo to my entry, so that I can keep a visual record of receipts or the items I didn't buy.
Acceptance Criteria:
'Add Photo' button in entry form
Option to take photo or choose from gallery
Photo thumbnail shown in entry
Tap thumbnail to view full size


Goal Setting & Tracking
US-007: Create Savings Goal
Priority: P0
User Story:
As a user, I want to set a savings goal, so that I have a specific target to work toward and stay motivated.
Acceptance Criteria:
'Create Goal' button in Goals tab
Form with: goal name, target amount, time period (monthly/yearly)
Optional start and end dates
Goal appears on home screen and goals tab


US-008: View Goal Progress
Priority: P0
User Story:
As a user, I want to see my progress toward my goals, so that I know how close I am to achieving them.
Acceptance Criteria:
Progress bar showing percentage complete
Display current amount saved vs. target amount
Show days remaining until goal deadline
Real-time updates as new entries are added


US-009: Goal Achievement Celebration
Priority: P1
User Story:
As a user, I want to be celebrated when I achieve a goal, so that I feel motivated to continue saving.
Acceptance Criteria:
Push notification when goal is reached
In-app celebration screen with congratulations message
Goal marked as completed and moved to archive
Option to create a new goal immediately


US-010: Manage Multiple Goals
Priority: P1
User Story:
As a user, I want to track multiple savings goals simultaneously, so that I can work toward different objectives at the same time.
Acceptance Criteria:
Can create unlimited active goals
Goals tab shows all active goals with progress
Can edit or delete goals
Home screen shows 2-3 most relevant active goals


Streak Tracking
US-011: Track Daily Streak
Priority: P0
User Story:
As a user, I want to see my current streak of consecutive days logging, so that I'm motivated to maintain the habit.
Acceptance Criteria:
Current streak displayed prominently on home screen
Streak increments when user logs at least one entry each day
Visual indicator (fire emoji or similar) shown with streak number
Streak resets to 0 if a day is missed


US-012: Milestone Badges
Priority: P1
User Story:
As a user, I want to earn badges at streak milestones, so that I feel rewarded for consistent behavior.
Acceptance Criteria:
Badges awarded at 7, 30, 60, 100, and 365-day streaks
Notification shown when badge is earned
Badges displayed in user profile or achievements section
Each badge has unique icon and description


US-013: Daily Reminder Notification
Priority: P1
User Story:
As a user, I want to receive a daily reminder to log my savings, so that I don't forget and break my streak.
Acceptance Criteria:
Optional notification enabled in settings
User can set preferred notification time
Notification only sent if no entry logged that day
Tapping notification opens app to entry form


US-014: View Longest Streak
Priority: P2
User Story:
As a user, I want to see my longest streak ever achieved, so that I have a personal record to beat.
Acceptance Criteria:
Longest streak displayed below current streak on home screen
Updates automatically when current streak exceeds previous record
Includes date range of when longest streak occurred


Data Visualizations
US-015: View Savings Over Time
Priority: P1
User Story:
As a user, I want to see a line chart of my savings over time, so that I can understand my saving trends.
Acceptance Criteria:
Line chart in Charts tab showing cumulative or daily savings
Toggle between weekly, monthly, and yearly views
Interactive chart with data point values on tap
Updates automatically as new entries are added


US-016: Category Breakdown
Priority: P1
User Story:
As a user, I want to see a pie chart of my savings by category, so that I know which types of actions are most effective.
Acceptance Criteria:
Pie chart showing percentage of total savings per category
Legend with category names and amounts
Can filter by time period (this month, this year, all time)
Tap segment to see category details


US-017: Summary Statistics
Priority: P2
User Story:
As a user, I want to see summary statistics about my savings, so that I can understand my overall performance.
Acceptance Criteria:
Display total saved (all time, this year, this month)
Show average savings per day/week/month
Identify most common category
Show total number of entries


History & Search
US-018: View Entry History
Priority: P0
User Story:
As a user, I want to view all my past entries in chronological order, so that I can review my saving history.
Acceptance Criteria:
History tab shows reverse chronological list of all entries
Each entry shows amount, category, note, timestamp
Smooth infinite scroll loading
Tap entry to view details or edit


US-019: Filter History
Priority: P1
User Story:
As a user, I want to filter my history by date and category, so that I can find specific entries more easily.
Acceptance Criteria:
Filter button opens filter options
Date range picker (from date, to date)
Category multi-select checkbox list
Applied filters shown as chips, can be removed individually
'Clear all filters' option


US-020: Search History
Priority: P2
User Story:
As a user, I want to search my history by keywords, so that I can quickly find entries with specific notes.
Acceptance Criteria:
Search bar at top of History tab
Searches entry notes and category names
Results update in real-time as user types
Highlights matched terms in results


Data Management & Settings
US-021: Export Data
Priority: P0
User Story:
As a user, I want to export all my data, so that I can back it up or transfer it to a new device.
Acceptance Criteria:
'Export Data' option in Settings
Choose export format: JSON or CSV
Includes all entries, goals, settings, and achievements
File can be saved to device storage or shared via system share sheet


US-022: Import Data
Priority: P0
User Story:
As a user, I want to import previously exported data, so that I can restore my information on a new device.
Acceptance Criteria:
'Import Data' option in Settings
File picker to select backup file
Warning shown if existing data will be overwritten
Progress indicator during import
Success/failure message after import completes


US-023: Customize Settings
Priority: P1
User Story:
As a user, I want to customize app settings, so that the app works the way I prefer.
Acceptance Criteria:
Currency selection with common currencies
Notification preferences: Enable/disable, set time
Backup reminder frequency: Never, Weekly, Monthly


US-024: Manage Custom Categories
Priority: P2
User Story:
As a user, I want to add and manage custom categories, so that I can organize my savings in a way that makes sense to me.
Acceptance Criteria:
'Manage Categories' option in Settings
List of all categories (pre-defined and custom)
Add new category with name input
Edit or delete custom categories
Cannot delete pre-defined categories




