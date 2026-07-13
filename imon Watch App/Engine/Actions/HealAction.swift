import Foundation

nonisolated enum HealAction {

    // MARK: - Query

    static func canHeal(_ state: PetState) -> Bool {
        !state.isDead && !state.isEgg && state.isInjured
    }

    // MARK: - Apply

    static func apply(to state: PetState) -> PetState {
        guard canHeal(state) else { return state }

        var state = state
        state.heal()
        return state
    }
}
