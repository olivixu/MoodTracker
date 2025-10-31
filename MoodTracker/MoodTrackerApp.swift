import SwiftUI
import SwiftData

@main
struct MoodTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MoodEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MoodTrackerMainView()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct MoodTrackerMainView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var moodManager: MoodManager?

    var body: some View {
        Group {
            if let manager = moodManager {
                MoodTrackerTabView(moodManager: manager)
            } else {
                ProgressView()
                    .onAppear {
                        moodManager = MoodManager(modelContext: modelContext)
                    }
            }
        }
    }
}

struct MoodTrackerTabView: View {
    @ObservedObject var moodManager: MoodManager

    var body: some View {
        TabView {
            MoodRecordingView(moodManager: moodManager)
                .tabItem {
                    Label("Today", systemImage: "chart.line.uptrend.xyaxis")
                }

            MoodHistoryView(moodManager: moodManager)
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
        }
    }
}
