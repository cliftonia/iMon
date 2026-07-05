import Foundation

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
        // Reset the poop timer so cleaning grants a fresh interval — otherwise a
        // pile nearly due could reappear minutes after the owner just tidied up.
        state.timestamps.lastPoopAt = now
        return state
    }
}
