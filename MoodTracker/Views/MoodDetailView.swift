import SwiftUI

struct MoodDetailView: View {
    let date: Date
    let moodManager: MoodManager

    @State private var entries: [MoodEntry] = []
    @State private var statistics: MoodStatistics?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Graph
                MoodGraphView(
                    entries: entries,
                    isInteractive: false,
                    showLabels: true
                )
                .frame(height: 300)
                .padding(.horizontal)

                // Statistics
                if let stats = statistics {
                    VStack(spacing: 16) {
                        Text("Statistics")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 12) {
                            StatCard(
                                title: "Average",
                                value: String(format: "%.1f", stats.average),
                                color: Color.moodColor(for: stats.average),
                                icon: "chart.bar.fill"
                            )

                            StatCard(
                                title: "Highest",
                                value: String(format: "%.1f", stats.highest),
                                color: Color.moodColor(for: stats.highest),
                                icon: "arrow.up.circle.fill"
                            )

                            StatCard(
                                title: "Lowest",
                                value: String(format: "%.1f", stats.lowest),
                                color: Color.moodColor(for: stats.lowest),
                                icon: "arrow.down.circle.fill"
                            )
                        }

                        StatCard(
                            title: "Total Recordings",
                            value: "\(stats.count)",
                            color: .blue,
                            icon: "list.bullet.circle.fill",
                            isWide: true
                        )
                    }
                    .padding(.horizontal)
                }

                // Timeline
                if !entries.isEmpty {
                    VStack(spacing: 16) {
                        Text("Timeline")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: 12) {
                            ForEach(entries, id: \.timeSlot) { entry in
                                TimelineRowView(entry: entry)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        entries = moodManager.fetchEntries(for: date)
        if !entries.isEmpty {
            statistics = MoodStatistics(
                average: moodManager.averageMood(for: entries),
                highest: entries.map(\.moodValue).max() ?? 0,
                lowest: entries.map(\.moodValue).min() ?? 0,
                count: entries.count
            )
        }
    }

    private var navigationTitle: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Statistics

struct MoodStatistics {
    let average: Double
    let highest: Double
    let lowest: Double
    let count: Int
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    var isWide: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .monospacedDigit()

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .frame(width: isWide ? nil : nil)
    }
}

// MARK: - Timeline Row

struct TimelineRowView: View {
    let entry: MoodEntry

    var body: some View {
        HStack(spacing: 16) {
            // Time
            VStack(alignment: .leading, spacing: 2) {
                Text(timeString)
                    .font(.headline)
                Text(periodOfDay)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 80, alignment: .leading)

            // Mood indicator
            ZStack {
                Circle()
                    .fill(moodColor.opacity(0.2))
                    .frame(width: 40, height: 40)

                Circle()
                    .fill(moodColor)
                    .frame(width: 12, height: 12)
            }

            // Mood value
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "%.1f", entry.moodValue))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                Text(entry.moodValue.moodLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var timeString: String {
        TimeSlotHelper.timeString(for: entry.timeSlot)
    }

    private var periodOfDay: String {
        let hour = entry.timeSlot / 6
        switch hour {
        case 0..<6: return "Night"
        case 6..<12: return "Morning"
        case 12..<17: return "Afternoon"
        case 17..<21: return "Evening"
        default: return "Night"
        }
    }

    private var moodColor: Color {
        Color.moodColor(for: entry.moodValue)
    }
}
