import Foundation

/// Medicine: clears the current injury. The lifetime `injuryCount` stays, so
/// repeated injuries still count toward `maxInjuriesBeforeDeath` — healing
/// treats the wound, it does not erase the history.
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
