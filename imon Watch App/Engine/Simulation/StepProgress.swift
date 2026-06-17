import Foundation

/// Accumulates real-world steps into the lifetime total that drives evolution.
///
/// Each day's fresh steps are folded into the lifetime total. Finishing a *lazy*
/// day (fewer than `lazyThreshold` steps) costs a `lazyPenalty` — so progression
/// rewards staying active rather than a single burst. All tuning lives here.
nonisolated enum StepProgress {

    /// A day below this step count is "lazy" and incurs the decay penalty.
    static let lazyThreshold = 2_000

    /// Lifetime steps removed for finishing a lazy day (floored at zero).
    static let lazyPenalty = 2_000

    /// The persisted accumulator triple, advanced as a unit.
    nonisolated struct Progress: Sendable, Equatable {
        var lifetime: Int
        var creditedToday: Int
        /// The calendar day `creditedToday` belongs to; `nil` until first credit.
        var trackedDay: Date?
    }

    /// Folds `todaySteps` into the accumulator, applying lazy-day decay on a
    /// calendar-day rollover. `todaySteps` is HealthKit's running total for the
    /// current day, so within a day we credit only the delta since last seen.
    static func advance(
        _ progress: Progress,
        todaySteps: Int,
        now: Date,
        calendar: Calendar = .current
    ) -> Progress {
        let today = max(0, todaySteps)

        // First credit ever — start tracking, no decay.
        guard let trackedDay = progress.trackedDay else {
            return Progress(
                lifetime: max(0, progress.lifetime) + today,
                creditedToday: today,
                trackedDay: now
            )
        }

        // Same day — credit only the increase since we last looked.
        if calendar.isDate(now, inSameDayAs: trackedDay) {
            let delta = max(0, today - progress.creditedToday)
            return Progress(
                lifetime: progress.lifetime + delta,
                creditedToday: max(progress.creditedToday, today),
                trackedDay: trackedDay
            )
        }

        // New day — settle the finished day (decay if it was lazy), then credit
        // today afresh. Multi-day gaps apply a single decay (approximate).
        let penalty = progress.creditedToday < lazyThreshold ? lazyPenalty : 0
        let settled = max(0, progress.lifetime - penalty)
        return Progress(
            lifetime: settled + today,
            creditedToday: today,
            trackedDay: now
        )
    }
}
