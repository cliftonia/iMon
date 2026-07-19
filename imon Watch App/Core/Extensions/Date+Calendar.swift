import Foundation

// MARK: - Calendar Conveniences

/// Store-side shorthand; engine code that needs a deterministic calendar
/// keeps taking one as a parameter instead of using these.
nonisolated extension Date {

    func isSameDay(as other: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: other)
    }
}
