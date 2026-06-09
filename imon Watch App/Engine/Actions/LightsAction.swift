import Foundation

nonisolated enum LightsAction {

    enum ToggleResult: Sendable {
        case toggled
        case blocked
    }

    // MARK: - Query

    /// The light can only be toggled at night. By day it is forced on, so any
    /// toggle (which could only turn it off) is refused.
    static func canToggle(_ state: PetState, night: Bool) -> Bool {
        !state.isDead && !state.isEgg && night
    }

    // MARK: - Apply

    @discardableResult
    static func apply(
        to state: PetState,
        night: Bool,
        at now: Date
    ) -> (state: PetState, result: ToggleResult) {
        guard canToggle(state, night: night) else {
            return (state, .blocked)
        }

        var state = state
        state.lightsOn.toggle()
        if state.lightsOn {
            // Turned on — wake immediately.
            state.isSleeping = false
            state.timestamps.lightsOffAt = nil
        } else {
            // Turned off — start the settle countdown; stay awake for now.
            state.timestamps.lightsOffAt = now
        }
        return (state, .toggled)
    }
}
