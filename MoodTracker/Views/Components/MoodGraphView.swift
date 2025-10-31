import SwiftUI

struct MoodGraphView: View {
    let entries: [MoodEntry]
    let currentSlot: Int?
    let currentMood: Double?
    let isInteractive: Bool
    let showLabels: Bool
    let totalSlots: Int
    let tomorrowSlots: Int

    init(
        entries: [MoodEntry],
        currentSlot: Int? = nil,
        currentMood: Double? = nil,
        isInteractive: Bool = false,
        showLabels: Bool = true,
        totalSlots: Int? = nil,
        tomorrowSlots: Int = 0
    ) {
        self.entries = entries
        self.currentSlot = currentSlot
        self.currentMood = currentMood
        self.isInteractive = isInteractive
        self.showLabels = showLabels
        self.totalSlots = totalSlots ?? TimeSlotHelper.slotsPerDay
        self.tomorrowSlots = tomorrowSlots
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Background grid
                GraphGrid(
                    showLabels: showLabels,
                    totalSlots: totalSlots,
                    tomorrowSlots: tomorrowSlots
                )

                // Mood line and area
                MoodPath(
                    entries: entries,
                    currentSlot: currentSlot,
                    currentMood: currentMood,
                    size: geometry.size,
                    totalSlots: totalSlots
                )

                // Current time indicator (only for interactive/today view)
                if isInteractive, let slot = currentSlot {
                    TimeIndicator(
                        slot: slot,
                        size: geometry.size,
                        totalSlots: totalSlots
                    )
                }
            }
        }
    }
}

// MARK: - Graph Grid

struct GraphGrid: View {
    let showLabels: Bool
    let totalSlots: Int
    let tomorrowSlots: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Horizontal grid lines (mood levels)
                ForEach(-5...5, id: \.self) { mood in
                    let y = yPosition(for: Double(mood), height: geometry.size.height)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(
                        mood == 0 ? Color.primary.opacity(0.3) : Color.gray.opacity(0.1),
                        lineWidth: mood == 0 ? 1.5 : 1
                    )

                    // Mood labels
                    if showLabels {
                        Text("\(mood)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .position(x: geometry.size.width - 15, y: y)
                    }
                }

                // Vertical grid lines (hours)
                if showLabels {
                    // Today's hours
                    ForEach(TimeSlotHelper.hourLabels(), id: \.slot) { item in
                        let x = xPosition(for: item.slot, width: geometry.size.width)
                        Path { path in
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                        }
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)

                        Text(item.label)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .position(x: x, y: geometry.size.height + 15)
                    }

                    // Tomorrow's hours (greyed out)
                    if tomorrowSlots > 0 {
                        let tomorrowHours = tomorrowSlots / 6 // Convert slots to hours
                        ForEach(0..<tomorrowHours + 1, id: \.self) { hour in
                            let slot = TimeSlotHelper.slotsPerDay + (hour * 6)
                            let x = xPosition(for: slot, width: geometry.size.width)
                            Path { path in
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                            }
                            .stroke(Color.gray.opacity(0.05), lineWidth: 1)

                            Text("\(hour)")
                                .font(.caption2)
                                .foregroundColor(.secondary.opacity(0.5))
                                .position(x: x, y: geometry.size.height + 15)
                        }

                        // "Tomorrow" label
                        let tomorrowStartX = xPosition(for: TimeSlotHelper.slotsPerDay, width: geometry.size.width)
                        Text("Tomorrow →")
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(0.6))
                            .position(x: tomorrowStartX + 40, y: -10)
                    }
                }
            }
        }
    }

    private func yPosition(for mood: Double, height: CGFloat) -> CGFloat {
        let normalized = (mood - TimeSlotHelper.moodMin) / (TimeSlotHelper.moodMax - TimeSlotHelper.moodMin)
        return height * (1 - normalized)
    }

    private func xPosition(for slot: Int, width: CGFloat) -> CGFloat {
        width * CGFloat(slot) / CGFloat(totalSlots)
    }
}

// MARK: - Mood Path

struct MoodPath: View {
    let entries: [MoodEntry]
    let currentSlot: Int?
    let currentMood: Double?
    let size: CGSize
    let totalSlots: Int

    var body: some View {
        ZStack {
            // Area fill
            Path { path in
                guard !dataPoints.isEmpty else { return }

                path.move(to: dataPoints[0])
                for point in dataPoints.dropFirst() {
                    path.addLine(to: point)
                }
                // Close the path to bottom
                path.addLine(to: CGPoint(x: dataPoints.last!.x, y: size.height))
                path.addLine(to: CGPoint(x: dataPoints[0].x, y: size.height))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // Line
            Path { path in
                guard !dataPoints.isEmpty else { return }

                path.move(to: dataPoints[0])
                for point in dataPoints.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(Color.blue, lineWidth: 2.5)

            // Data point dots
            ForEach(Array(dataPoints.enumerated()), id: \.offset) { _, point in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
                    .position(point)
            }
        }
    }

    private var dataPoints: [CGPoint] {
        var points: [CGPoint] = []

        // Add all saved entries
        for entry in entries {
            let x = size.width * CGFloat(entry.timeSlot) / CGFloat(totalSlots)
            let normalizedMood = (entry.moodValue - TimeSlotHelper.moodMin) / (TimeSlotHelper.moodMax - TimeSlotHelper.moodMin)
            let y = size.height * (1 - normalizedMood)
            points.append(CGPoint(x: x, y: y))
        }

        // Add current position if provided
        if let slot = currentSlot, let mood = currentMood {
            let x = size.width * CGFloat(slot) / CGFloat(totalSlots)
            let normalizedMood = (mood - TimeSlotHelper.moodMin) / (TimeSlotHelper.moodMax - TimeSlotHelper.moodMin)
            let y = size.height * (1 - normalizedMood)
            points.append(CGPoint(x: x, y: y))
        }

        return points
    }
}

// MARK: - Time Indicator

struct TimeIndicator: View {
    let slot: Int
    let size: CGSize
    let totalSlots: Int

    var body: some View {
        let x = size.width * CGFloat(slot) / CGFloat(totalSlots)

        Path { path in
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
        }
        .stroke(Color.red.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
    }
}
