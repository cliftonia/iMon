import Foundation

/// Tracks care mistakes when hunger or strength is empty for longer
/// than `careMistakeWindow` (20 min). Uses `pendingCareMistakeAt` to
/// record when the neglect period began.
nonisolated enum CareMistakeTracker {

    static func apply(to state: PetState, at now: Date) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg else { return state }

        // Lights-on-while-sleeping penalty (runs regardless of sleep state)
        state = trackLightsMistake(state: state, at: now)

        // Hunger/strength neglect only applies while awake
        guard !state.isSleeping else { return state }

        let needsAttention = state.hungerHearts.isEmpty || state.strengthHearts.isEmpty

        if needsAttention {
            if let pendingAt = state.pendingCareMistakeAt {
                let elapsed = now.timeIntervalSince(pendingAt)
                let mistakes = Int(elapsed / TimeConstants.careMistakeWindow)
                if mistakes > 0 {
                    state.careMistakes += mistakes
                    state.pendingCareMistakeAt = pendingAt.addingTimeInterval(
                        Double(mistakes) * TimeConstants.careMistakeWindow
                    )
                }
            } else {
                state.pendingCareMistakeAt = now
            }
        } else {
            state.pendingCareMistakeAt = nil
        }

        return state
    }

    // MARK: - Lights Penalty

    private static func trackLightsMistake(
        state: PetState,
        at now: Date
    ) -> PetState {
        var state = state
        let lightsOnWhileSleeping = state.isSleeping && state.lightsOn

        if lightsOnWhileSleeping {
            if let pendingAt = state.pendingLightsMistakeAt {
                let elapsed = now.timeIntervalSince(pendingAt)
                let mistakes = Int(elapsed / TimeConstants.careMistakeWindow)
                if mistakes > 0 {
                    state.careMistakes += mistakes
                    state.pendingLightsMistakeAt = pendingAt.addingTimeInterval(
                        Double(mistakes) * TimeConstants.careMistakeWindow
                    )
                }
            } else {
                state.pendingLightsMistakeAt = now
            }
        } else {
            state.pendingLightsMistakeAt = nil
        }

        return state
    }
}
