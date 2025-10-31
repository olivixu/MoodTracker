# Mood Tracker

A beautiful, intuitive iOS app for tracking your mood throughout the day using interactive graphs.

## Features

### 🎯 Core Features
- **Interactive Mood Recording**: Drag a handle vertically to set your current mood (-5 to +5 scale)
- **10-Minute Intervals**: Automatic time slot advancement every 10 minutes
- **Real-time Graph**: Visual timeline showing your mood throughout the day
- **History Tracking**: Browse all previously recorded days with mini graph previews
- **Detailed Statistics**: View average, highest, and lowest moods for any day
- **Timeline View**: See your mood changes with timestamps and labels

### ✨ Polish
- Smooth animations and haptic feedback
- Dark mode support
- Clean, minimal design
- Locked past data (can't edit previous time slots)
- Color-coded mood indicators
- Emoji mood representations

## Technical Details

### Architecture
- **SwiftUI** for all UI components
- **SwiftData** for persistent storage
- **MVVM** pattern with `ObservableObject`
- **Combine** for timer management

### Project Structure
```
MoodTracker/
├── MoodTrackerApp.swift          # Main app entry point
├── Models/
│   └── MoodEntry.swift           # SwiftData model
├── ViewModels/
│   └── MoodManager.swift         # State management & timer logic
├── Views/
│   ├── MoodRecordingView.swift  # Today tab (interactive)
│   ├── MoodHistoryView.swift    # History list
│   ├── MoodDetailView.swift     # Day detail view
│   └── Components/
│       └── MoodGraphView.swift  # Reusable graph component
└── Utilities/
    └── TimeSlotHelper.swift      # Time slot calculations
```

### Data Model
- **144 time slots per day** (10-minute intervals)
- **Mood scale**: -5.0 to +5.0
- **Local storage only** (SwiftData)
- **Automatic persistence**

## Setup & Running

### Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Build Instructions

1. **Open in Xcode**:
   ```bash
   cd /Users/oliviaxu/mood-tracker
   xed .
   ```

2. **Create an Xcode Project**:
   - Open Xcode
   - Create a new iOS App project
   - Name: "MoodTracker"
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None (we're using SwiftData manually)

3. **Add Files**:
   - Replace the default ContentView.swift and MoodTrackerApp.swift with the provided files
   - Add all other source files to the project maintaining the folder structure

4. **Configure Project**:
   - Set minimum deployment target to iOS 17.0
   - Add Info.plist if needed
   - Set app icon and display name

5. **Build & Run**:
   - Select a simulator or device
   - Press Cmd+R to build and run

## Usage

### Recording Mood
1. Open the app to the "Today" tab
2. Drag the blue handle up or down to set your current mood
3. Your mood is automatically saved for the current 10-minute time slot
4. The handle advances automatically every 10 minutes

### Viewing History
1. Switch to the "History" tab
2. Browse all days with recorded moods
3. Tap any day to see detailed statistics and timeline
4. Pull to refresh the list

## Key Components

### MoodManager
Manages all state, timer logic, and data persistence:
- Auto-advances time slots every 10 minutes
- Saves mood entries to SwiftData
- Fetches historical data
- Calculates statistics

### MoodGraphView
Reusable graph component used in both recording and history views:
- Renders mood data as a line graph with gradient fill
- Shows grid lines and labels
- Supports interactive and read-only modes

### DraggableHandle
The interactive component for mood recording:
- Smooth drag gesture with haptic feedback
- Visual feedback (scaling, shadows)
- Clamps values to valid range

## Future Enhancements

Potential features to add:
- [ ] Export data as CSV
- [ ] Mood trends/analytics (weekly, monthly)
- [ ] Notes for each mood entry
- [ ] Reminder notifications
- [ ] Widgets for quick entry
- [ ] Custom mood scales
- [ ] Color themes
- [ ] Apple Watch companion app
- [ ] iCloud sync
- [ ] Share mood graphs as images

## Privacy

All data is stored locally on your device using SwiftData. No data is transmitted to external servers or shared with third parties.

## License

This project is provided as-is for personal use and learning purposes.
