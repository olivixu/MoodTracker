import Foundation
import SwiftData

@Model
final class MoodEntry {
    var date: Date
    var timeSlot: Int // 0-143 (144 ten-minute slots per day)
    var moodValue: Double // -5.0 to +5.0

    init(date: Date, timeSlot: Int, moodValue: Double) {
        self.date = date
        self.timeSlot = timeSlot
        self.moodValue = moodValue
    }

    // Helper computed property to get the exact timestamp for this entry
    var timestamp: Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let minutes = timeSlot * 10
        return calendar.date(byAdding: .minute, value: minutes, to: startOfDay) ?? startOfDay
    }
}
