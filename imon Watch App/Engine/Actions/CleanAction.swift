import Foundation

nonisolated enum CleanAction {

    // MARK: - Query

    static func canClean(_ state: PetState) -> Bool {
        !state.isDead && !state.isEgg && state.poopCount > 0
    }

    // MARK: - Apply

    static func apply(to state: PetState, at date: Date = .now) -> PetState {
        guard canClean(state) else { return state }

        var state = state
        state.poopCount = 0
        return state
    }
}
