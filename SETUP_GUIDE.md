# Mood Tracker - Xcode Setup Guide

This guide will walk you through setting up the Mood Tracker app in Xcode.

## Prerequisites
- macOS with Xcode 15.0 or later
- iOS 17.0+ SDK
- Basic familiarity with Xcode

## Step-by-Step Setup

### 1. Create a New Xcode Project

1. Open Xcode
2. Select **File → New → Project** (or press ⌘⇧N)
3. Choose **iOS** → **App** template
4. Click **Next**

### 2. Configure Project Settings

Fill in the project details:
- **Product Name**: `MoodTracker`
- **Team**: Select your development team (or leave as None for simulator testing)
- **Organization Identifier**: Use your preferred identifier (e.g., `com.yourname`)
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: **None** (we'll use SwiftData manually)
- **Include Tests**: Optional (uncheck if not needed)

Click **Next** and choose a location to save (you can save to the current directory)

### 3. Add Source Files to Xcode

You have two options:

#### Option A: Add Existing Files
1. In Xcode's Project Navigator (left sidebar), right-click on the **MoodTracker** folder
2. Select **Add Files to "MoodTracker"...**
3. Navigate to your mood-tracker directory
4. Select all `.swift` files and folders:
   - `Models/` folder
   - `ViewModels/` folder
   - `Views/` folder
   - `Utilities/` folder
   - `MoodTrackerApp.swift` (replace the existing one)
5. Make sure **"Copy items if needed"** is checked
6. Click **Add**

#### Option B: Drag and Drop
1. Open Finder and navigate to the mood-tracker directory
2. Drag the following folders into Xcode's Project Navigator:
   - `Models/`
   - `ViewModels/`
   - `Views/`
   - `Utilities/`
3. Replace the default `MoodTrackerApp.swift` with the one from the project

### 4. Configure Build Settings

1. Select the **MoodTracker** project in the Project Navigator
2. Select the **MoodTracker** target
3. Go to the **General** tab:
   - **Minimum Deployments**: Set to **iOS 17.0**
   - **Supported Destinations**: Ensure **iPhone** is checked

4. Go to the **Info** tab:
   - If prompted, you can use the `Info.plist` file included in the project

### 5. File Structure Verification

Your project should have this structure:

```
MoodTracker/
├── MoodTrackerApp.swift
├── Models/
│   └── MoodEntry.swift
├── ViewModels/
│   └── MoodManager.swift
├── Views/
│   ├── MoodRecordingView.swift
│   ├── MoodHistoryView.swift
│   ├── MoodDetailView.swift
│   └── Components/
│       └── MoodGraphView.swift
├── Utilities/
│   ├── TimeSlotHelper.swift
│   └── ColorExtension.swift
└── Assets.xcassets (auto-generated)
```

### 6. Build and Run

1. Select a simulator from the device dropdown (e.g., **iPhone 15 Pro**)
2. Press **⌘R** or click the **Play** button to build and run
3. The app should launch in the simulator

## Troubleshooting

### "No such module 'SwiftData'"
- Ensure your deployment target is iOS 17.0 or later
- Clean build folder: **Product → Clean Build Folder** (⌘⇧K)
- Restart Xcode

### "Cannot find type 'MoodEntry' in scope"
- Make sure all files are added to the target
- Check file membership: Select each file and verify the target checkbox is checked in the File Inspector

### Build errors about missing files
- Verify all source files are in the project
- Check that file paths are correct in the Project Navigator
- Try cleaning and rebuilding

### Timer not working
- The timer uses `Timer.publish` which requires the app to be in the foreground
- Test on a real device or ensure the simulator is active

### Dark mode issues
- The app should automatically support dark mode
- Test by toggling dark mode in the simulator: **Settings → Developer → Dark Appearance**

## Testing the App

### Recording Mood
1. Launch the app to the "Today" tab
2. Drag the circular handle up or down
3. Notice the emoji and color change based on mood value
4. Wait for 10 minutes (or advance simulator time) to see auto-progression

### Viewing History
1. Record some mood entries
2. Switch to the "History" tab
3. Tap on any day to see detailed statistics
4. Swipe back to return to the list

## Optional Enhancements

### Custom App Icon
1. Create or download an app icon (1024x1024 PNG)
2. In Xcode, open **Assets.xcassets**
3. Click on **AppIcon**
4. Drag your icon into the 1024x1024 slot

### Display Name
1. Select the project in Project Navigator
2. Go to **General** tab
3. Change **Display Name** to your preferred name

### Launch Screen
1. Open **Assets.xcassets**
2. Add a color set for the launch screen background
3. The Info.plist already configures the launch screen

## Running on Physical Device

1. Connect your iPhone via USB
2. Select your device from the device dropdown
3. If prompted, trust the computer on your iPhone
4. You may need to set a development team:
   - Go to **Signing & Capabilities** tab
   - Check **Automatically manage signing**
   - Select your team
5. Build and run (⌘R)

## Data Persistence

- All mood data is stored locally using SwiftData
- Data persists between app launches
- To reset data: Delete and reinstall the app, or use the simulator's **Device → Erase All Content and Settings**

## Performance Tips

- The app is optimized for smooth scrolling and animations
- Graph rendering uses SwiftUI's native drawing APIs
- Timer is efficient and runs in the background when app is active

## Next Steps

Once the app is running:
1. Try dragging the mood handle to different values
2. Record multiple mood entries throughout the day
3. Check the History tab to see your mood patterns
4. Explore the detail view for statistics

## Support

If you encounter issues:
1. Check the console output in Xcode for error messages
2. Verify all files are properly added to the target
3. Ensure deployment target is iOS 17.0+
4. Try cleaning the build folder and rebuilding

---

Happy mood tracking! 📊😊
