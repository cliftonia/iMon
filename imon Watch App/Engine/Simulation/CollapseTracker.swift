import Foundation

/// Tracks the collapse countdown: a pet with no hunger *and* no strength is
/// languishing. `collapsingAt` marks when that began; left untended past
/// `collapseDeathTime`, `DeathEvaluator` ends it. Recovering either stat clears
/// the countdown.
nonisolated enum CollapseTracker {

    static func apply(to state: PetState, at now: Date) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg else { return state }

        if state.isLanguishing {
            if state.timestamps.collapsingAt == nil {
                state.timestamps.collapsingAt = now
            }
        } else {
            state.timestamps.collapsingAt = nil
        }
        return state
    }
}
