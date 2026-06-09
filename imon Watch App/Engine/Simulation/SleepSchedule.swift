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

    /// Apply the resolved night signal to the light and sleep state. At night
    /// the pet only drops off `sleepDelay` seconds after the light goes out.
    static func apply(to state: PetState, at now: Date, night: Bool) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg else { return state }

        // Dusk/dawn: flip the light automatically on the transition.
        if night != state.wasNight {
            state.lightsOn = !night
            state.wasNight = night
        }

        guard night else {
            // Daytime is always lit and awake.
            state.lightsOn = true
            state.isSleeping = false
            state.timestamps.lightsOffAt = nil
            return state
        }

        // Night, light on — wide awake.
        if state.lightsOn {
            state.isSleeping = false
            state.timestamps.lightsOffAt = nil
        } else if state.isSleeping {
            // Already settled — stay asleep, no countdown.
            state.timestamps.lightsOffAt = nil
        } else if let offAt = state.timestamps.lightsOffAt {
            // Light is off — drop off once the settle delay has passed.
            if now.timeIntervalSince(offAt) >= TimeConstants.sleepDelay {
                state.isSleeping = true
                state.timestamps.lightsOffAt = nil
            }
        } else {
            // Light just went out — start the settle countdown.
            state.timestamps.lightsOffAt = now
        }

        return state
    }

    /// Whether a given hour falls within a species' fixed sleep window.
    static func isSleepTime(hour: Int, for species: PetSpecies) -> Bool {
        hour >= species.bedtimeHour || hour < species.wakeHour
    }
}
