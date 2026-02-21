import Foundation

/// Depletes hunger hearts based on elapsed time since `lastHungerDecayAt`.
/// One heart lost per `hungerDepletionInterval` (70 min).
nonisolated enum HungerSimulator {

    static func apply(to state: PetState, at now: Date) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg, !state.isSleeping else { return state }

        let elapsed = now.timeIntervalSince(state.lastHungerDecayAt)
        let ticks = Int(elapsed / TimeConstants.hungerDepletionInterval)
        guard ticks > 0 else { return state }

        for _ in 0..<ticks {
            state.hungerHearts.decrement()
        }

        state.lastHungerDecayAt = state.lastHungerDecayAt.addingTimeInterval(
            Double(ticks) * TimeConstants.hungerDepletionInterval
        )
        return state
    }
}
