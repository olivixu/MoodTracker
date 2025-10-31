import SwiftUI

struct MoodRecordingView: View {
    @ObservedObject var moodManager: MoodManager
    @State private var isDragging = false
    @State private var zoomScale: CGFloat = 2.5

    private let minZoom: CGFloat = 1.0
    private let maxZoom: CGFloat = 6.0

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Current mood display
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Mood")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(moodManager.currentMoodValue.moodEmoji)
                            .font(.system(size: 50))
                            .contentTransition(.numericText())
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "%.1f", moodManager.currentMoodValue))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color.moodColor(for: moodManager.currentMoodValue))
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(nil, value: moodManager.currentMoodValue)
                        Text(TimeSlotHelper.timeString(for: moodManager.currentTimeSlot))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .padding()
                .background(Color.moodColor(for: moodManager.currentMoodValue).opacity(0.1))
                .cornerRadius(16)
                .animation(nil, value: moodManager.currentMoodValue)

                // Interactive graph with zoom & pan
                GeometryReader { geometry in
                    let baseWidth = geometry.size.width
                    let currentHour = moodManager.currentTimeSlot / 6
                    let showTomorrow = currentHour >= 18 // Show tomorrow if after 6pm
                    let tomorrowSlots = showTomorrow ? 36 : 0 // 6 hours = 36 slots
                    let totalSlots = TimeSlotHelper.slotsPerDay + tomorrowSlots
                    let scaledWidth = baseWidth * zoomScale * CGFloat(totalSlots) / CGFloat(TimeSlotHelper.slotsPerDay)

                    ScrollViewReader { scrollProxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            ZStack(alignment: .leading) {
                                // Scroll anchor positioned at current time
                                HStack(spacing: 0) {
                                    Color.clear
                                        .frame(width: scaledWidth * CGFloat(moodManager.currentTimeSlot) / CGFloat(totalSlots))
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: 1, height: geometry.size.height - 60)
                                        .id("currentTime")
                                    Color.clear
                                        .frame(width: scaledWidth * CGFloat(totalSlots - moodManager.currentTimeSlot) / CGFloat(totalSlots))
                                }
                                .padding(.vertical, 30)

                                // Graph content
                                MoodGraphView(
                                    entries: moodManager.todayEntries.filter { $0.timeSlot < moodManager.currentTimeSlot },
                                    currentSlot: moodManager.currentTimeSlot,
                                    currentMood: moodManager.currentMoodValue,
                                    isInteractive: true,
                                    showLabels: true,
                                    totalSlots: totalSlots,
                                    tomorrowSlots: tomorrowSlots
                                )
                                .frame(width: scaledWidth, height: geometry.size.height - 60)
                                .padding(.vertical, 30)
                                .padding(.bottom, 30)

                                // Draggable handle overlay
                                DraggableHandle(
                                    moodValue: $moodManager.currentMoodValue,
                                    isDragging: $isDragging,
                                    currentTimeSlot: moodManager.currentTimeSlot,
                                    geometrySize: CGSize(width: scaledWidth, height: geometry.size.height - 60),
                                    totalSlots: totalSlots,
                                    onDragChange: { value in
                                        moodManager.updateMood(value, withHaptic: false)
                                    },
                                    onDragEnd: {
                                        moodManager.updateMood(moodManager.currentMoodValue, withHaptic: true)
                                    }
                                )
                                .padding(.vertical, 30)
                            }
                        }
                        .onAppear {
                            // Auto-scroll to center current time
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    scrollProxy.scrollTo("currentTime", anchor: .center)
                                }
                            }
                        }
                        .onChange(of: moodManager.currentTimeSlot) { oldValue, newValue in
                            // Re-center when time slot changes
                            withAnimation(.easeOut(duration: 0.5)) {
                                scrollProxy.scrollTo("currentTime", anchor: .center)
                            }
                        }
                        .onChange(of: zoomScale) { oldValue, newValue in
                            // Re-center when zoom changes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    scrollProxy.scrollTo("currentTime", anchor: .center)
                                }
                            }
                        }
                    }
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let newScale = max(minZoom, min(maxZoom, value))
                                zoomScale = newScale
                            }
                    )
                }
                .frame(height: 300)
                .padding(.horizontal)

                // Instructions
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "hand.draw.fill")
                            .foregroundColor(.blue)
                        Text("Drag the handle to record your current mood")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .foregroundColor(.green)
                        Text("Pinch to zoom • Swipe to pan graph")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if moodManager.currentTimeSlot < TimeSlotHelper.slotsPerDay - 1 {
                        let nextSlotTime = TimeSlotHelper.timeString(for: moodManager.currentTimeSlot + 1)
                        Text("Next recording at \(nextSlotTime)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.7), trigger: moodManager.triggerHaptic)
        }
    }
}

// MARK: - Draggable Handle

struct DraggableHandle: View {
    @Binding var moodValue: Double
    @Binding var isDragging: Bool
    let currentTimeSlot: Int
    let geometrySize: CGSize
    let totalSlots: Int
    let onDragChange: (Double) -> Void
    let onDragEnd: () -> Void

    private let handleSize: CGFloat = 44

    var body: some View {
        let yPosition = yPositionForMood(moodValue)
        let xPosition = xPositionForTimeSlot(currentTimeSlot)
        let handleColor = Color.moodColor(for: moodValue)

        Circle()
            .fill(handleColor)
            .frame(width: handleSize, height: handleSize)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 3)
            )
            .shadow(color: handleColor.opacity(0.5), radius: isDragging ? 12 : 6, x: 0, y: 2)
            .animation(nil, value: moodValue)
            .scaleEffect(isDragging ? 1.2 : 1.0)
            .position(x: xPosition, y: yPosition)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        // Clamp Y position to stay within graph bounds
                        let clampedY = max(0, min(geometrySize.height, value.location.y))
                        let newMood = moodForYPosition(clampedY)
                        onDragChange(newMood)
                    }
                    .onEnded { _ in
                        isDragging = false
                        onDragEnd()
                    }
            )
    }

    private func yPositionForMood(_ mood: Double) -> CGFloat {
        guard geometrySize.height > 0 else { return 0 }
        let normalized = (mood - TimeSlotHelper.moodMin) / (TimeSlotHelper.moodMax - TimeSlotHelper.moodMin)
        return geometrySize.height * (1 - normalized)
    }

    private func xPositionForTimeSlot(_ slot: Int) -> CGFloat {
        guard geometrySize.width > 0 else { return 0 }
        return geometrySize.width * CGFloat(slot) / CGFloat(totalSlots)
    }

    private func moodForYPosition(_ y: CGFloat) -> Double {
        guard geometrySize.height > 0 else { return 0 }
        let normalized = 1 - (y / geometrySize.height)
        let mood = normalized * (TimeSlotHelper.moodMax - TimeSlotHelper.moodMin) + TimeSlotHelper.moodMin
        return TimeSlotHelper.clampMood(mood)
    }
}
