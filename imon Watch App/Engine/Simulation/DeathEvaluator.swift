import Foundation

/// Decides whether a death threshold in `TimeConstants` has killed the pet,
/// and applies it. Evaluation and application are split so `GameEngine.step`
/// can log the `CauseOfDeath` between deciding and flipping the flag; pure
/// value in, value out, like the simulators.
nonisolated enum DeathEvaluator {

    nonisolated enum CauseOfDeath: Sendable {
        case injuries
        case untreatedInjury
        case collapse
    }

    // MARK: - Evaluate

    /// Returns the cause of death once a threshold is met, or `nil` while the
    /// pet is alive. Eggs and pets already dead are ineligible. When several
    /// thresholds are met at once the first check wins: lifetime `injuryCount`,
    /// then an untreated injury older than `untreatedInjuryDeathTime`, then
    /// the collapse countdown `CollapseTracker` started.
    static func evaluate(_ state: PetState, at now: Date) -> CauseOfDeath? {
        guard !state.isDead, !state.isEgg else { return nil }

        if state.injuryCount >= TimeConstants.maxInjuriesBeforeDeath {
            return .injuries
        }

        if state.isInjured, let injuredAt = state.timestamps.injuredAt {
            let elapsed = now.timeIntervalSince(injuredAt)
            if elapsed >= TimeConstants.untreatedInjuryDeathTime {
                return .untreatedInjury
            }
        }

        if let collapsingAt = state.timestamps.collapsingAt {
            let elapsed = now.timeIntervalSince(collapsingAt)
            if elapsed >= TimeConstants.collapseDeathTime {
                return .collapse
            }
        }

        return nil
    }

    // MARK: - Apply

    static func applyDeath(to state: PetState) -> PetState {
        var state = state
        state.isDead = true
        return state
    }
}
