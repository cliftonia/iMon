import Foundation

/// Cleaning flushes every poop pile in one go; there is no per-pile scoop.
nonisolated enum CleanAction {

    // MARK: - Query

    static func canClean(_ state: PetState) -> Bool {
        !state.isDead && !state.isEgg && state.poopCount > 0
    }

    // MARK: - Apply

    static func apply(to state: PetState, at now: Date = .now) -> PetState {
        guard canClean(state) else { return state }

        var state = state
        state.poopCount = 0
        // Reset the timer — a pile nearly due must not reappear right after cleaning.
        state.timestamps.lastPoopAt = now
        return state
    }
}
