import Foundation

/// Evaluates whether the pet becomes injured during a simulation tick.
/// A pet gets injured when poop reaches the maximum pile count.
nonisolated enum InjurySimulator {

    static func apply(to state: PetState, at now: Date, steps: Int? = nil) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg, !state.isSleeping, !state.isInjured else {
            return state
        }

        // A sedentary wearer makes the pet injury-prone: poop injures one pile
        // sooner than usual.
        let sedentary = steps.map { ActivityModel.isSedentary(steps: $0) } ?? false
        let threshold = sedentary
            ? TimeConstants.maxPoopPiles - 1
            : TimeConstants.maxPoopPiles

        if state.poopCount >= threshold {
            state.isInjured = true
            state.timestamps.injuredAt = now
            state.injuryCount += 1
        }

        return state
    }
}
