import Foundation

/// Depletes hunger hearts based on elapsed time since `lastHungerDecayAt`.
/// One heart lost per `hungerDepletionInterval` (70 min).
nonisolated enum HungerSimulator {

    static func apply(to state: PetState, at now: Date) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg, !state.isSleeping else { return state }

        let ticks = TickMath.ticks(
            from: state.timestamps.lastHungerDecayAt,
            to: now,
            interval: TimeConstants.hungerDepletionInterval
        )
        guard ticks > 0 else { return state }

        for _ in 0..<ticks {
            state.hungerHearts.decrement()
        }

        state.timestamps.lastHungerDecayAt = state.timestamps.lastHungerDecayAt.addingTimeInterval(
            Double(ticks) * TimeConstants.hungerDepletionInterval
        )
        return state
    }
}
