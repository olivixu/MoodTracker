import Foundation

struct TimeSlotHelper {
    static let slotsPerDay = 144 // 24 hours * 6 (10-minute intervals per hour)
    static let minutesPerSlot = 10
    static let moodMin: Double = -5.0
    static let moodMax: Double = 5.0

    // Get current time slot (0-143) for a given date
    static func currentTimeSlot(for date: Date = Date()) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let totalMinutes = hour * 60 + minute
        return min(totalMinutes / minutesPerSlot, slotsPerDay - 1)
    }

    // Get the start of day for a given date
    static func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    // Check if a date is today
    static func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    // Get time string for a time slot (e.g., "14:30")
    static func timeString(for slot: Int) -> String {
        let hours = slot / 6
        let minutes = (slot % 6) * 10
        return String(format: "%02d:%02d", hours, minutes)
    }

    // Get hour labels for graph (0, 3, 6, 9, 12, 15, 18, 21)
    static func hourLabels() -> [(slot: Int, label: String)] {
        stride(from: 0, to: 24, by: 3).map { hour in
            (slot: hour * 6, label: "\(hour)")
        }
    }

    // Clamp mood value to valid range
    static func clampMood(_ value: Double) -> Double {
        max(moodMin, min(moodMax, value))
    }

    // Get time until next slot in seconds
    static func secondsUntilNextSlot(from date: Date = Date()) -> TimeInterval {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        let minute = components.minute ?? 0
        let second = components.second ?? 0

        let minuteInSlot = minute % 10
        let secondsIntoSlot = minuteInSlot * 60 + second
        let secondsPerSlot = TimeInterval(minutesPerSlot * 60)

        return secondsPerSlot - TimeInterval(secondsIntoSlot)
    }
}
