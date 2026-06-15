import Foundation

/// Depletes hunger hearts based on elapsed time since `lastHungerDecayAt`.
/// One heart lost per `hungerDepletionInterval` (70 min).
nonisolated enum HungerSimulator {

    static func apply(to state: PetState, at now: Date, steps: Int? = nil) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg, !state.isSleeping else { return state }

        // Hunger depletes faster the more the wearer moves.
        let multiplier = steps.map { ActivityModel.hungerRateMultiplier(steps: $0) } ?? 1.0
        let interval = TimeConstants.hungerDepletionInterval / multiplier
        let ticks = TickMath.ticks(
            from: state.timestamps.lastHungerDecayAt,
            to: now,
            interval: interval
        )
        guard ticks > 0 else { return state }

        for _ in 0..<ticks {
            state.hungerHearts.decrement()
        }

        state.timestamps.lastHungerDecayAt = state.timestamps.lastHungerDecayAt
            .addingTimeInterval(Double(ticks) * interval)
        return state
    }
}
