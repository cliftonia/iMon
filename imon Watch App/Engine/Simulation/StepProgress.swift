import Foundation

/// Accumulates real-world steps into the lifetime total that drives evolution.
///
/// Each day's fresh steps are folded into the (only-ever-growing) lifetime total.
/// Finishing a *lazy* day (fewer than `lazyThreshold` steps) instead raises the
/// evolution goal by a stage-scaled penalty - so progression rewards staying
/// active rather than a single burst. All tuning lives here and in `EvolutionStage`.
nonisolated enum StepProgress {

    /// A day below this step count is "lazy" and raises the evolution goal.
    static let lazyThreshold = 2_000

    /// The persisted evolution accumulator, advanced as a unit.
    nonisolated struct Progress: Sendable, Equatable {
        var lifetime: Int
        var creditedToday: Int
        /// The calendar day `creditedToday` belongs to; `nil` until first credit.
        var trackedDay: Date?
        /// Extra steps the lazy-day penalties have added to the evolution goal.
        var goalPenalty: Int
    }

    /// Folds `todaySteps` into the accumulator, charging a lazy day's
    /// `stagePenalty` to the evolution goal on a calendar-day rollover.
    /// `todaySteps` is HealthKit's running total for the current day, so within a
    /// day we credit only the delta since last seen.
    static func advance(
        _ progress: Progress,
        todaySteps: Int,
        now: Date,
        stagePenalty: Int,
        calendar: Calendar = .current
    ) -> Progress {
        let today = max(0, todaySteps)

        // First credit ever - baseline today's running total and start tracking,
        // without crediting it. Folding `today` into the lifetime here would
        // retroactively award steps taken before this pet existed: a pet hatched
        // mid-day, or a fresh pet after a death/reset, would inherit the day's
        // earlier count. From here on, only the post-baseline delta is credited.
        guard let trackedDay = progress.trackedDay else {
            return Progress(
                lifetime: max(0, progress.lifetime),
                creditedToday: today,
                trackedDay: now,
                goalPenalty: progress.goalPenalty
            )
        }

        // Same day - credit only the increase since we last looked.
        if calendar.isDate(now, inSameDayAs: trackedDay) {
            let delta = max(0, today - progress.creditedToday)
            return Progress(
                lifetime: progress.lifetime + delta,
                creditedToday: max(progress.creditedToday, today),
                trackedDay: trackedDay,
                goalPenalty: progress.goalPenalty
            )
        }

        // New day - a lazy finished day raises the goal, then credit today afresh.
        // Multi-day gaps apply a single penalty (approximate).
        let penalty = progress.creditedToday < lazyThreshold ? stagePenalty : 0
        return Progress(
            lifetime: progress.lifetime + today,
            creditedToday: today,
            trackedDay: now,
            goalPenalty: progress.goalPenalty + penalty
        )
    }
}
