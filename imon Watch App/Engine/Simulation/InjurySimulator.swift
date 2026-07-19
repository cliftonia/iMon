import Foundation

/// Evaluates whether the pet becomes injured during a simulation tick.
/// A pet gets injured when poop reaches the maximum pile count.
nonisolated enum InjurySimulator {

    /// `steps` (today's running count) lowers the injuring pile threshold by
    /// one for a sedentary wearer; `nil` is treated as not sedentary.
    static func apply(to state: PetState, at now: Date, steps: Int? = nil) -> PetState {
        var state = state
        guard state.isAwakeAndAlive, !state.isInjured else { return state }

        // A sedentary wearer is injury-prone: poop injures one pile sooner.
        let sedentary = steps.map { ActivityModel.isSedentary(steps: $0) } ?? false
        let threshold = sedentary
            ? TimeConstants.maxPoopPiles - 1
            : TimeConstants.maxPoopPiles

        if state.poopCount >= threshold {
            state.injure(at: now)
        }

        return state
    }
}
