import Foundation

// MARK: - Calendar Conveniences

/// Same-day comparisons defaulting to the current calendar.
/// Engine code keeps taking a `Calendar` parameter instead of using these,
/// so its date arithmetic stays deterministic.
nonisolated extension Date {

    func isSameDay(as other: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: other)
    }
}
