import Foundation

/// Adds poop piles based on elapsed time since `lastPoopAt`.
/// One poop every `poopInterval` (2 hours). Max 4 piles.
nonisolated enum PoopSimulator {

    static func apply(to state: PetState, at now: Date) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg, !state.isSleeping else { return state }

        let elapsed = now.timeIntervalSince(state.lastPoopAt)
        let newPoops = Int(elapsed / TimeConstants.poopInterval)
        guard newPoops > 0 else { return state }

        state.poopCount = min(TimeConstants.maxPoopPiles, state.poopCount + newPoops)
        state.lastPoopAt = state.lastPoopAt.addingTimeInterval(
            Double(newPoops) * TimeConstants.poopInterval
        )
        return state
    }
}
