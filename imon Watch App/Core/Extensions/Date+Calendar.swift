import Foundation

// MARK: - Calendar Conveniences
//
// Shorthand for the current-calendar checks sprinkled through the stores.
// Engine code that needs a deterministic calendar keeps taking one as a
// parameter instead of using these.

nonisolated extension Date {

    /// Whether this date falls on the same calendar day as `other`.
    func isSameDay(as other: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: other)
    }
}
