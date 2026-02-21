import Foundation

nonisolated enum LightsAction {

    enum ToggleResult: Sendable {
        case toggled
        case toggledDuringSleep
        case blocked
    }

    // MARK: - Query

    static func canToggle(_ state: PetState) -> Bool {
        !state.isDead && !state.isEgg
    }

    // MARK: - Apply

    @discardableResult
    static func apply(
        to state: PetState,
        at now: Date
    ) -> (state: PetState, result: ToggleResult) {
        guard canToggle(state) else {
            return (state, .blocked)
        }

        var state = state
        state.lightsOn.toggle()

        let hour = Calendar.current.component(.hour, from: now)
        let duringSleep = SleepSchedule.isSleepTime(
            hour: hour, for: state.species
        )

        if duringSleep {
            state.lightsToggledDuringSleepAt = now
            return (state, .toggledDuringSleep)
        }

        return (state, .toggled)
    }
}
