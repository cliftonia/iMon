import Foundation

/// Depletes strength hearts based on elapsed time since `lastStrengthDecayAt`.
/// One heart lost per `strengthDepletionInterval` (60 min).
nonisolated enum StrengthSimulator {

    static func apply(to state: PetState, at now: Date) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg, !state.isSleeping else { return state }

        let elapsed = now.timeIntervalSince(state.lastStrengthDecayAt)
        let ticks = Int(elapsed / TimeConstants.strengthDepletionInterval)
        guard ticks > 0 else { return state }

        for _ in 0..<ticks {
            state.strengthHearts.decrement()
        }

        state.lastStrengthDecayAt = state.lastStrengthDecayAt.addingTimeInterval(
            Double(ticks) * TimeConstants.strengthDepletionInterval
        )
        return state
    }
}
