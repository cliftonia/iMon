import Foundation

/// Evaluates whether the pet becomes injured during a simulation tick.
/// A pet gets injured when poop reaches the maximum pile count.
nonisolated enum InjurySimulator {

    static func apply(to state: PetState, at now: Date) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg, !state.isSleeping, !state.isInjured else {
            return state
        }

        if state.poopCount >= TimeConstants.maxPoopPiles {
            state.isInjured = true
            state.injuredAt = now
            state.injuryCount += 1
        }

        return state
    }
}
