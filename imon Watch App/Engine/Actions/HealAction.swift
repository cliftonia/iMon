import Foundation

nonisolated enum HealAction {

    // MARK: - Query

    static func canHeal(_ state: PetState) -> Bool {
        !state.isDead && !state.isEgg && state.isInjured
    }

    // MARK: - Apply

    static func apply(to state: PetState, at date: Date = .now) -> PetState {
        guard canHeal(state) else { return state }

        var state = state
        state.isInjured = false
        state.injuredAt = nil
        return state
    }
}
