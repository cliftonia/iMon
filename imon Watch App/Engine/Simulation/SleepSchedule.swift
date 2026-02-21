import Foundation

/// Determines if the pet should be sleeping based on the current hour
/// and the species' bedtime/wake schedule.
nonisolated enum SleepSchedule {

    static func apply(to state: PetState, at now: Date) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg else { return state }

        let hour = Calendar.current.component(.hour, from: now)
        let shouldSleep = isSleepTime(hour: hour, for: state.species)

        if shouldSleep, !state.isSleeping {
            state.isSleeping = true
            state.lightsOn = false
        } else if !shouldSleep, state.isSleeping {
            state.isSleeping = false
            state.lightsOn = true
        }

        return state
    }

    /// Check if a given hour falls within sleep hours for a species.
    static func isSleepTime(hour: Int, for species: DigimonSpecies) -> Bool {
        hour >= species.bedtimeHour || hour < species.wakeHour
    }
}
