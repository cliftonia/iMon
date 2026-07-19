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

        // Baseline only — a fresh pet must not inherit steps taken before it existed.
        guard let trackedDay = progress.trackedDay else {
            return Progress(
                lifetime: max(0, progress.lifetime),
                creditedToday: today,
                trackedDay: now,
                goalPenalty: progress.goalPenalty
            )
        }

        if calendar.isDate(now, inSameDayAs: trackedDay) {
            let delta = max(0, today - progress.creditedToday)
            return Progress(
                lifetime: progress.lifetime + delta,
                creditedToday: max(progress.creditedToday, today),
                trackedDay: trackedDay,
                goalPenalty: progress.goalPenalty
            )
        }

        // Multi-day gaps charge a single lazy-day penalty (approximate).
        let penalty = progress.creditedToday < lazyThreshold ? stagePenalty : 0
        return Progress(
            lifetime: progress.lifetime + today,
            creditedToday: today,
            trackedDay: now,
            goalPenalty: progress.goalPenalty + penalty
        )
    }
}

// MARK: - PetState Mapping

nonisolated extension StepProgress.Progress {

    /// Packs the accumulator from the pet state's four persisted fields.
    init(of state: PetState) {
        self.init(
            lifetime: state.lifetimeActiveSteps,
            creditedToday: state.stepsCreditedToday,
            trackedDay: state.stepTrackedDay,
            goalPenalty: state.evolutionGoalPenalty
        )
    }

    /// Writes the accumulator back into the pet state's four persisted fields.
    func write(to state: inout PetState) {
        state.lifetimeActiveSteps = lifetime
        state.stepsCreditedToday = creditedToday
        state.stepTrackedDay = trackedDay
        state.evolutionGoalPenalty = goalPenalty
    }
}
