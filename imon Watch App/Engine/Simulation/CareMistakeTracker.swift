import Foundation

/// Tracks care mistakes when hunger or strength is empty for longer
/// than `careMistakeWindow` (20 min). Uses `pendingCareMistakeAt` to
/// record when the neglect period began.
nonisolated enum CareMistakeTracker {

    static func apply(to state: PetState, at now: Date, night: Bool) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg else { return state }

        // Light left on at night keeps the pet awake — a care mistake.
        state = trackLightsMistake(state: state, at: now, night: night)

        // Hunger/strength neglect only applies while awake
        guard !state.isSleeping else { return state }

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
        night: Bool
    ) -> PetState {
        var state = state
        let keptAwakeAtNight = night && state.lightsOn

        if keptAwakeAtNight {
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
