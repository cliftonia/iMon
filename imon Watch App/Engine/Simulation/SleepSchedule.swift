import Foundation

/// Drives sleep and the light from a single day/night signal.
///
/// - **Day:** the light is always on and the pet is awake.
/// - **Night:** the light is the player's switch; the pet sleeps when it's off.
/// - **Transitions:** dusk turns the light off (pet sleeps), dawn turns it on
///   (pet wakes). `wasNight` records the last state so we only act on a change.
nonisolated enum SleepSchedule {

    /// Resolve whether it is night: the weather's daylight flag when available,
    /// otherwise the species' fixed bedtime/wake hours.
    static func isNight(
        weatherNight: Bool?,
        at now: Date,
        for species: PetSpecies
    ) -> Bool {
        if let weatherNight { return weatherNight }
        let hour = Calendar.current.component(.hour, from: now)
        return isSleepTime(hour: hour, for: species)
    }

    /// Apply the resolved night signal to the light and sleep state.
    static func apply(to state: PetState, night: Bool) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg else { return state }

        // Dusk/dawn: flip the light automatically on the transition.
        if night != state.wasNight {
            state.lightsOn = !night
            state.wasNight = night
        }

        if night {
            // The player owns the light at night; sleep follows it.
            state.isSleeping = !state.lightsOn
        } else {
            // Daytime is always lit and awake.
            state.lightsOn = true
            state.isSleeping = false
        }

        return state
    }

    /// Whether a given hour falls within a species' fixed sleep window.
    static func isSleepTime(hour: Int, for species: PetSpecies) -> Bool {
        hour >= species.bedtimeHour || hour < species.wakeHour
    }
}
