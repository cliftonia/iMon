import Foundation

/// Drives sleep and the light from a single day/night signal.
///
/// - **Day:** the light is always on and the pet is awake.
/// - **Night:** the light is the player's switch; the pet sleeps when it's off.
/// - **Transitions:** dusk turns the light off (pet sleeps), dawn turns it on
///   (pet wakes). `wasNight` records the last state so we only act on a change.
nonisolated enum SleepSchedule {

    /// Whether it is night. Always defer to the weather's daylight flag; only
    /// when no reading is available fall back to a fixed window (6am–6pm is day,
    /// the rest is night).
    static func isNight(
        weatherNight: Bool?,
        at now: Date,
        calendar: Calendar = .current
    ) -> Bool {
        if let weatherNight { return weatherNight }
        let hour = calendar.component(.hour, from: now)
        return hour < TimeConstants.nightEndHour || hour >= TimeConstants.nightStartHour
    }

    /// The pet's bedtime window — it only settles to sleep from `sleepHour` (9pm)
    /// until the morning wake hour. Outside it the pet stays up, even after dark.
    static func isBedtime(at now: Date, calendar: Calendar = .current) -> Bool {
        let hour = calendar.component(.hour, from: now)
        return hour >= TimeConstants.sleepHour || hour < TimeConstants.nightEndHour
    }

    /// Apply the resolved night signal to the light and sleep state. The pet only
    /// drops off once it's past bedtime and the light has been out for `sleepDelay`.
    static func apply(to state: PetState, at now: Date, night: Bool) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg else { return state }

        // Dusk/dawn: flip the light automatically on the day↔night transition.
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

        let bedtime = isBedtime(at: now)

        if state.lightsOn || !bedtime {
            // Light on (brought inside), or dark-but-not-yet-bedtime — wide awake.
            state.isSleeping = false
            state.timestamps.lightsOffAt = nil
        } else if state.isSleeping {
            // Already settled — stay asleep, no countdown.
            state.timestamps.lightsOffAt = nil
        } else if let offAt = state.timestamps.lightsOffAt {
            // Past bedtime, light out — drop off once the settle delay has passed.
            if now.timeIntervalSince(offAt) >= TimeConstants.sleepDelay {
                state.isSleeping = true
                state.timestamps.lightsOffAt = nil
            }
        } else {
            // Bedtime, light just went out — start the settle countdown.
            state.timestamps.lightsOffAt = now
        }

        return state
    }
}
