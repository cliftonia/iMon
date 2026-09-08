import Foundation

/// The player's light switch. Turning it off at night starts the settle
/// countdown that `SleepSchedule` turns into sleep; turning it on wakes the
/// pet immediately. Day toggles are refused — daylight forces the light on.
nonisolated enum LightsAction {

    nonisolated enum ToggleResult: Sendable {
        case toggled
        case blocked
    }

    // MARK: - Query

    /// Reports whether the light can be toggled: night only, and never while
    /// the pet is dead or still an egg.
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
            state.wake(at: now)
        } else {
            // Settle countdown anchor; the pet stays awake until
            // `SleepSchedule` turns it into sleep.
            state.timestamps.lightsOffAt = now
        }
        return (state, .toggled)
    }
}
