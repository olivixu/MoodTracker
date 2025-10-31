import SwiftUI

struct MoodHistoryView: View {
    @ObservedObject var moodManager: MoodManager
    @State private var allDays: [Date] = []

    var body: some View {
        NavigationStack {
            Group {
                if allDays.isEmpty {
                    ContentUnavailableView(
                        "No History Yet",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Start tracking your mood to see your history here")
                    )
                } else {
                    List {
                        ForEach(allDays, id: \.self) { day in
                            NavigationLink(destination: MoodDetailView(date: day, moodManager: moodManager)) {
                                DayRowView(date: day, moodManager: moodManager)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadDays()
            }
            .refreshable {
                loadDays()
            }
        }
    }

    private func loadDays() {
        allDays = moodManager.fetchAllDays()
    }
}

// MARK: - Day Row View

struct DayRowView: View {
    let date: Date
    let moodManager: MoodManager

    @State private var entries: [MoodEntry] = []
    @State private var averageMood: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateString)
                        .font(.headline)
                    Text(relativeDateString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Average mood indicator
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1f", averageMood))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.moodColor(for: averageMood))
                        .monospacedDigit()
                    Text("avg")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Mini graph preview
            MoodGraphView(
                entries: entries,
                isInteractive: false,
                showLabels: false
            )
            .frame(height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 8)
        .onAppear {
            loadEntries()
        }
    }

    private func loadEntries() {
        entries = moodManager.fetchEntries(for: date)
        averageMood = moodManager.averageMood(for: entries)
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private var relativeDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
            return "\(daysAgo) days ago"
        }
    }
}
