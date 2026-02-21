import Foundation

nonisolated enum LightsAction {

    // MARK: - Query

    static func canToggle(_ state: PetState) -> Bool {
        !state.isDead && !state.isEgg
    }

    // MARK: - Apply

    static func apply(to state: PetState) -> PetState {
        guard canToggle(state) else { return state }

        var state = state
        state.lightsOn.toggle()
        return state
    }
}
