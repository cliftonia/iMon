import Foundation

/// Determines if the pet should be sleeping based on the current hour
/// and the species' bedtime/wake schedule.
nonisolated enum SleepSchedule {

    static func apply(to state: PetState, at now: Date) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg else { return state }

        let hour = Calendar.current.component(.hour, from: now)
        let sleepTime = isSleepTime(hour: hour, for: state.species)

        // 1. Resolve pending toggle if delay has elapsed
        state = resolvePendingToggle(state: state, at: now)

        // 2. Bedtime transition
        if sleepTime,
           !state.isSleeping,
           state.lightsToggledDuringSleepAt == nil {
            state.isSleeping = true
            state.lightsOn = false
        }

        // 3. Leaving sleep hours — clear any user override
        if !sleepTime {
            if state.isSleeping {
                state.isSleeping = false
                state.lightsOn = true
            }
            state.lightsToggledDuringSleepAt = nil
        }

        return state
    }

    /// Check if a given hour falls within sleep hours for a species.
    static func isSleepTime(hour: Int, for species: DigimonSpecies) -> Bool {
        hour >= species.bedtimeHour || hour < species.wakeHour
    }

    // MARK: - Private

    private static func resolvePendingToggle(
        state: PetState,
        at now: Date
    ) -> PetState {
        guard let toggledAt = state.lightsToggledDuringSleepAt else {
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
            state.lightsToggledDuringSleepAt = nil
        }
        return state
    }
}
