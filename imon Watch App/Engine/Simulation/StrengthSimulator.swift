import Foundation

/// Depletes strength hearts based on elapsed time since `lastStrengthDecayAt`.
/// One heart lost per `strengthDepletionInterval` (60 min).
nonisolated enum StrengthSimulator {

    static func apply(to state: PetState, at now: Date, steps: Int? = nil) -> PetState {
        var state = state
        guard state.isAwakeAndAlive else { return state }

        // Strength depletes faster the less the wearer moves (more vitamins).
        let multiplier = steps.map { ActivityModel.strengthRateMultiplier(steps: $0) } ?? 1.0
        HeartDecay.deplete(
            &state.strengthHearts,
            anchor: &state.timestamps.lastStrengthDecayAt,
            baseInterval: TimeConstants.strengthDepletionInterval,
            multiplier: multiplier,
            at: now
        )
        return state
    }
}
