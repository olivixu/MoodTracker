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
        guard height > 0 else { return 0 }
        let normalized = (mood - TimeSlotHelper.moodMin) / (TimeSlotHelper.moodMax - TimeSlotHelper.moodMin)
        return height * (1 - normalized)
    }

    private func xPosition(for slot: Int, width: CGFloat) -> CGFloat {
        guard width > 0 else { return 0 }
        return width * CGFloat(slot) / CGFloat(totalSlots)
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

                createSmoothPath(in: &path, through: dataPoints)
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
            .animation(nil, value: dataPoints)
            .drawingGroup()

            // Line
            Path { path in
                guard !dataPoints.isEmpty else { return }

                createSmoothPath(in: &path, through: dataPoints)
            }
            .stroke(Color.blue, lineWidth: 2.5)
            .animation(nil, value: dataPoints)
            .drawingGroup()

            // Data point dots
            ForEach(Array(dataPoints.enumerated()), id: \.offset) { _, point in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
                    .position(point)
            }
        }
    }

    private func createSmoothPath(in path: inout Path, through points: [CGPoint]) {
        guard points.count > 0 else { return }

        path.move(to: points[0])

        if points.count == 1 {
            return
        }

        if points.count == 2 {
            path.addLine(to: points[1])
            return
        }

        // Use Centripetal Catmull-Rom (alpha = 0.5) for smooth curves through points
        // This guarantees no loops or overshoots
        let alpha: CGFloat = 0.5  // Centripetal parameterization

        // Add ghost points at start and end for proper curve boundaries
        var extendedPoints: [CGPoint] = []

        // Ghost point before first (extrapolate backward)
        let ghostStart = points[0] + (points[0] - points[1])
        extendedPoints.append(ghostStart)

        // Add all actual points
        extendedPoints.append(contentsOf: points)

        // Ghost point after last (extrapolate forward)
        let ghostEnd = points[points.count - 1] + (points[points.count - 1] - points[points.count - 2])
        extendedPoints.append(ghostEnd)

        // Draw Catmull-Rom segments
        for i in 0..<points.count - 1 {
            let p0 = extendedPoints[i]
            let p1 = extendedPoints[i + 1]
            let p2 = extendedPoints[i + 2]
            let p3 = extendedPoints[i + 3]

            addCatmullRomSegment(to: &path, p0: p0, p1: p1, p2: p2, p3: p3, alpha: alpha)
        }
    }

    private func addCatmullRomSegment(
        to path: inout Path,
        p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint,
        alpha: CGFloat
    ) {
        // Calculate knot intervals using centripetal parameterization
        let t0: CGFloat = 0.0
        let t1 = t0 + pow(p1.distance(to: p0), alpha)
        let t2 = t1 + pow(p2.distance(to: p1), alpha)
        let t3 = t2 + pow(p3.distance(to: p2), alpha)

        // Handle degenerate cases
        guard t1 != t0 && t2 != t1 && t3 != t2 else {
            path.addLine(to: p2)
            return
        }

        // Calculate tangents at p1 and p2
        let m1 = ((p1 - p0) / (t1 - t0) - (p2 - p0) / (t2 - t0) + (p2 - p1) / (t2 - t1)) * (t2 - t1)
        let m2 = ((p2 - p1) / (t2 - t1) - (p3 - p1) / (t3 - t1) + (p3 - p2) / (t3 - t2)) * (t2 - t1)

        // Convert to cubic Bezier control points
        let cp1 = p1 + m1 / 3.0
        let cp2 = p2 - m2 / 3.0

        path.addCurve(to: p2, control1: cp1, control2: cp2)
    }

    private var dataPoints: [CGPoint] {
        guard size.width > 0 && size.height > 0 else { return [] }

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

// MARK: - CGPoint Extensions for Catmull-Rom

extension CGPoint {
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * scalar, y: point.y * scalar)
    }

    static func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x / scalar, y: point.y / scalar)
    }

    func distance(to point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}
