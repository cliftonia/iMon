import Foundation

/// Evaluates whether the pet has met a death condition and applies the
/// resulting state change.
nonisolated enum DeathEvaluator {

    nonisolated enum CauseOfDeath: Sendable {
        case careMistakes
        case injuries
        case untreatedInjury
    }

    // MARK: - Evaluate

    /// Returns the cause of death if a threshold is met, or `nil` if the pet is alive.
    static func evaluate(_ state: PetState, at now: Date) -> CauseOfDeath? {
        guard !state.isDead, !state.isEgg else { return nil }

        if state.careMistakes >= TimeConstants.maxCareMistakesBeforeDeath {
            return .careMistakes
        }

        if state.injuryCount >= TimeConstants.maxInjuriesBeforeDeath {
            return .injuries
        }

        if state.isInjured, let injuredAt = state.injuredAt {
            let elapsed = now.timeIntervalSince(injuredAt)
            if elapsed >= TimeConstants.untreatedInjuryDeathTime {
                return .untreatedInjury
            }
        }

        return nil
    }

    // MARK: - Apply

    /// Marks the pet as dead.
    static func applyDeath(to state: PetState) -> PetState {
        var state = state
        state.isDead = true
        return state
    }
}
