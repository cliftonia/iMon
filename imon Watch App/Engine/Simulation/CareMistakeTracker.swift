import Foundation

/// Tracks care mistakes when hunger or strength is empty for longer
/// than `careMistakeWindow` (20 min). Uses `pendingCareMistakeAt` to
/// record when the neglect period began.
nonisolated enum CareMistakeTracker {

    static func apply(to state: PetState, at now: Date, bedtime: Bool) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg else { return state }

        // Light left on past bedtime keeps the pet awake — a care mistake. (Before
        // bedtime the pet is allowed to be up in a lit room, so no penalty.)
        state = trackLightsMistake(state: state, at: now, bedtime: bedtime)

        // Hunger/strength neglect only applies while awake. Reset the pending
        // clock while asleep so the first waking tick doesn't back-fill the whole
        // night at once (a sparse background wake would otherwise count hours).
        guard !state.isSleeping else {
            state.timestamps.pendingCareMistakeAt = nil
            return state
        }

        let needsAttention = state.hungerHearts.isEmpty || state.strengthHearts.isEmpty

        if needsAttention {
            if let pendingAt = state.timestamps.pendingCareMistakeAt {
                let mistakes = TickMath.ticks(
                    from: pendingAt, to: now,
                    interval: TimeConstants.careMistakeWindow
                )
                if mistakes > 0 {
                    state.careMistakes += mistakes
                    state.timestamps.pendingCareMistakeAt = pendingAt.addingTimeInterval(
                        Double(mistakes) * TimeConstants.careMistakeWindow
                    )
                }
            } else {
                state.timestamps.pendingCareMistakeAt = now
            }
        } else {
            state.timestamps.pendingCareMistakeAt = nil
        }

        return state
    }

    // MARK: - Lights Penalty

    private static func trackLightsMistake(
        state: PetState,
        at now: Date,
        bedtime: Bool
    ) -> PetState {
        var state = state
        let keptAwakePastBedtime = bedtime && state.lightsOn

        if keptAwakePastBedtime {
            if let pendingAt = state.timestamps.pendingLightsMistakeAt {
                let mistakes = TickMath.ticks(
                    from: pendingAt, to: now,
                    interval: TimeConstants.careMistakeWindow
                )
                if mistakes > 0 {
                    state.careMistakes += mistakes
                    state.timestamps.pendingLightsMistakeAt = pendingAt.addingTimeInterval(
                        Double(mistakes) * TimeConstants.careMistakeWindow
                    )
                }
            } else {
                state.timestamps.pendingLightsMistakeAt = now
            }
        } else {
            state.timestamps.pendingLightsMistakeAt = nil
        }

        return state
    }
}
