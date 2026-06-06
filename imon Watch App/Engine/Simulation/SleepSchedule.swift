import Foundation

/// Determines if the pet should be sleeping based on the current hour
/// and the species' bedtime/wake schedule. The dark screen ("night mode")
/// can additionally follow real-world daylight via `isNight`.
nonisolated enum SleepSchedule {

    /// - Parameter isNight: when non-nil (e.g. from WeatherKit daylight),
    ///   drives the dark screen so it follows the real sunset/sunrise. Sleep
    ///   itself stays on the fixed bedtime/wake hours regardless.
    static func apply(
        to state: PetState,
        at now: Date,
        isNight: Bool? = nil
    ) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg else { return state }

        let hour = Calendar.current.component(.hour, from: now)
        let sleepTime = isSleepTime(hour: hour, for: state.species)

        // 1. Resolve pending toggle if delay has elapsed
        state = resolvePendingToggle(state: state, at: now)

        // 2. Bedtime transition
        if sleepTime,
           !state.isSleeping,
           state.timestamps.lightsToggledDuringSleepAt == nil {
            state.isSleeping = true
            state.lightsOn = false
        }

        // 3. Leaving sleep hours — clear any user override
        if !sleepTime {
            if state.isSleeping {
                state.isSleeping = false
                state.lightsOn = true
            }
            state.timestamps.lightsToggledDuringSleepAt = nil
        }

        // 4. Dark mode follows real-world night even while awake (winter dusk
        //    is earlier than bedtime), unless the user is mid lights-toggle.
        if let isNight,
           !state.isSleeping,
           state.timestamps.lightsToggledDuringSleepAt == nil {
            state.lightsOn = !isNight
        }

        return state
    }

    /// Check if a given hour falls within sleep hours for a species.
    static func isSleepTime(hour: Int, for species: PetSpecies) -> Bool {
        hour >= species.bedtimeHour || hour < species.wakeHour
    }

    // MARK: - Private

    private static func resolvePendingToggle(
        state: PetState,
        at now: Date
    ) -> PetState {
        guard let toggledAt = state.timestamps.lightsToggledDuringSleepAt else {
            return state
        }

        let elapsed = now.timeIntervalSince(toggledAt)
        guard elapsed >= TimeConstants.lightsToggleSleepDelay else {
            return state
        }

        var state = state
        if state.lightsOn {
            state.isSleeping = false
        } else {
            state.isSleeping = true
            state.timestamps.lightsToggledDuringSleepAt = nil
        }
        return state
    }
}
