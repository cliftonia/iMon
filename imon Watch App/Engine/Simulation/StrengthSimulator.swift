import Foundation

/// Depletes strength hearts based on elapsed time since `lastStrengthDecayAt`.
/// One heart lost per `strengthDepletionInterval` (60 min).
nonisolated enum StrengthSimulator {

    static func apply(to state: PetState, at now: Date, steps: Int? = nil) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg, !state.isSleeping else { return state }

        // Strength depletes faster the less the wearer moves (more vitamins).
        let multiplier = steps.map { ActivityModel.strengthRateMultiplier(steps: $0) } ?? 1.0
        let interval = TimeConstants.strengthDepletionInterval / multiplier
        let ticks = TickMath.ticks(
            from: state.timestamps.lastStrengthDecayAt,
            to: now,
            interval: interval
        )
        guard ticks > 0 else { return state }

        for _ in 0..<ticks {
            state.strengthHearts.decrement()
        }

        state.timestamps.lastStrengthDecayAt = state.timestamps.lastStrengthDecayAt
            .addingTimeInterval(Double(ticks) * interval)
        return state
    }
}
