import Foundation
import SwiftData
import Combine

@MainActor
class MoodManager: ObservableObject {
    @Published var currentMoodValue: Double = 0.0
    @Published var currentTimeSlot: Int = 0
    @Published var todayEntries: [MoodEntry] = []
    @Published var triggerHaptic: Bool = false

    private var modelContext: ModelContext
    private var timer: AnyCancellable?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.currentTimeSlot = TimeSlotHelper.currentTimeSlot()

        // Load today's entries
        loadTodayEntries()

        // Set initial mood to last recorded value or 0
        if let lastEntry = todayEntries.last {
            currentMoodValue = lastEntry.moodValue
        }

        // Start timer to advance time slots
        startTimer()
    }

    // MARK: - Timer Management

    private func startTimer() {
        // Calculate time until next slot
        let timeUntilNext = TimeSlotHelper.secondsUntilNextSlot()

        // Schedule first transition
        DispatchQueue.main.asyncAfter(deadline: .now() + timeUntilNext) { [weak self] in
            self?.advanceTimeSlot()
            self?.startPeriodicTimer()
        }
    }

    private func startPeriodicTimer() {
        // After initial sync, check every 10 minutes
        timer = Timer.publish(every: 600, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.advanceTimeSlot()
            }
    }

    private func advanceTimeSlot() {
        let newSlot = TimeSlotHelper.currentTimeSlot()
        if newSlot != currentTimeSlot {
            // Save current mood value before advancing
            saveMoodEntry()
            currentTimeSlot = newSlot
            triggerHaptic.toggle() // Trigger haptic feedback
        }
    }

    // MARK: - Data Management

    func loadTodayEntries() {
        let today = TimeSlotHelper.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { entry in
                entry.date >= today && entry.date < tomorrow
            },
            sortBy: [SortDescriptor(\.timeSlot)]
        )

        do {
            todayEntries = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch today's entries: \(error)")
            todayEntries = []
        }
    }

    func saveMoodEntry() {
        let today = TimeSlotHelper.startOfDay(for: Date())

        // Check if entry already exists for this slot
        if let existingEntry = todayEntries.first(where: { $0.timeSlot == currentTimeSlot }) {
            existingEntry.moodValue = currentMoodValue
        } else {
            let entry = MoodEntry(
                date: today,
                timeSlot: currentTimeSlot,
                moodValue: currentMoodValue
            )
            modelContext.insert(entry)
            todayEntries.append(entry)
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save mood entry: \(error)")
        }
    }

    func updateMood(_ value: Double, withHaptic: Bool = true) {
        currentMoodValue = TimeSlotHelper.clampMood(value)
        if withHaptic {
            triggerHaptic.toggle() // Trigger haptic feedback
        }
    }

    // MARK: - History Management

    func fetchAllDays() -> [Date] {
        let descriptor = FetchDescriptor<MoodEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        do {
            let allEntries = try modelContext.fetch(descriptor)
            // Get unique dates
            let uniqueDates = Set(allEntries.map { TimeSlotHelper.startOfDay(for: $0.date) })
            return Array(uniqueDates).sorted(by: >)
        } catch {
            print("Failed to fetch all days: \(error)")
            return []
        }
    }

    func fetchEntries(for date: Date) -> [MoodEntry] {
        let startOfDay = TimeSlotHelper.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            },
            sortBy: [SortDescriptor(\.timeSlot)]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch entries for date: \(error)")
            return []
        }
    }

    func averageMood(for entries: [MoodEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        return entries.reduce(0) { $0 + $1.moodValue } / Double(entries.count)
    }

    // MARK: - Cleanup

    deinit {
        timer?.cancel()
    }
}
