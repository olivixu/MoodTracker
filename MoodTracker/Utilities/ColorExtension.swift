import SwiftUI

extension Color {
    // Mood-based colors that work in both light and dark mode
    static func moodColor(for moodValue: Double) -> Color {
        switch moodValue {
        case 4...5: return .green
        case 2..<4: return Color(red: 0.2, green: 0.7, blue: 0.9) // Light blue
        case 0.5..<2: return .blue
        case -0.5..<0.5: return .gray
        case -2..<(-0.5): return .orange
        case -4..<(-2): return Color(red: 1.0, green: 0.4, blue: 0.3) // Light red
        default: return .red
        }
    }

    // Gradient colors for mood visualization
    static func moodGradient(for moodValue: Double) -> LinearGradient {
        let color = moodColor(for: moodValue)
        return LinearGradient(
            colors: [color.opacity(0.6), color.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// Mood emoji helper
extension Double {
    var moodEmoji: String {
        switch self {
        case 4...5: return "🤩"
        case 2..<4: return "😊"
        case 0.5..<2: return "🙂"
        case -0.5..<0.5: return "😐"
        case -2..<(-0.5): return "😕"
        case -4..<(-2): return "😞"
        default: return "😢"
        }
    }

    var moodLabel: String {
        switch self {
        case 4...5: return "Excellent"
        case 2..<4: return "Good"
        case 0.5..<2: return "Okay"
        case -0.5..<0.5: return "Neutral"
        case -2..<(-0.5): return "Low"
        case -4..<(-2): return "Bad"
        default: return "Very Low"
        }
    }
}
