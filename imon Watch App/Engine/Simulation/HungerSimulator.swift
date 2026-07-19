import Foundation

/// Depletes hunger hearts based on elapsed time since `lastHungerDecayAt`.
/// One heart lost per `hungerDepletionInterval` (70 min).
nonisolated enum HungerSimulator {

    /// `steps` (today's running count) speeds depletion via
    /// `ActivityModel.hungerRateMultiplier`; `nil` keeps the base rate.
    static func apply(to state: PetState, at now: Date, steps: Int? = nil) -> PetState {
        var state = state
        guard state.isAwakeAndAlive else { return state }

        // Hunger depletes faster the more the wearer moves.
        let multiplier = steps.map { ActivityModel.hungerRateMultiplier(steps: $0) } ?? 1.0
        HeartDecay.deplete(
            &state.hungerHearts,
            anchor: &state.timestamps.lastHungerDecayAt,
            baseInterval: TimeConstants.hungerDepletionInterval,
            multiplier: multiplier,
            at: now
        )
        return state
    }
}
