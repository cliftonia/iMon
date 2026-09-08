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

    /// How many days of clock boundaries a single catch-up replays. A pet
    /// neglected longer than this has long since collapsed, so later nights
    /// change nothing.
    static let maxReplayDays = 14

    /// The clock moments strictly between `start` and `end` at which the fixed
    /// schedule changes the pet's state — dusk (light off), bedtime (the settle
    /// begins), the settle itself (sleep) and dawn (wake) — in order. A catch-up
    /// that steps through them sleeps through a night the app never saw instead
    /// of charging it as waking hours. Dawn without a preceding settle still
    /// matters: it is where a pet that was asleep at `start` wakes.
    static func replayBoundaries(
        from start: Date,
        to end: Date,
        calendar: Calendar = .current
    ) -> [Date] {
        guard end > start else { return [] }
        let hours = [TimeConstants.nightEndHour, TimeConstants.nightStartHour, TimeConstants.sleepHour]
        var boundaries: [Date] = []
        var day = calendar.startOfDay(for: start)

        for _ in 0..<maxReplayDays {
            for hour in hours {
                guard let moment = calendar.date(
                    bySettingHour: hour, minute: 0, second: 0, of: day
                ) else { continue }
                boundaries.append(moment)
                if hour == TimeConstants.sleepHour {
                    boundaries.append(moment.addingTimeInterval(TimeConstants.sleepDelay))
                }
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: day), next < end else { break }
            day = next
        }
        return boundaries.filter { $0 > start && $0 < end }.sorted()
    }

    /// Applies the resolved night signal to the light and sleep state. The pet only
    /// drops off once it's past bedtime and the light has been out for `sleepDelay`;
    /// waking goes through `PetState.wake(at:)` so the sleep counts as a pause.
    static func apply(to state: PetState, at now: Date, night: Bool) -> PetState {
        var state = state
        guard !state.isDead, !state.isEgg else { return state }

        // Dusk/dawn: flip the light automatically on the day↔night transition.
        if night != state.wasNight {
            state.lightsOn = !night
            state.wasNight = night
        }

        guard night else {
            state.lightsOn = true
            state.wake(at: now)
            return state
        }

        let bedtime = isBedtime(at: now)

        if state.lightsOn || !bedtime {
            state.wake(at: now)
        } else if state.isSleeping {
            state.timestamps.lightsOffAt = nil
        } else if let offAt = state.timestamps.lightsOffAt {
            if now.timeIntervalSince(offAt) >= TimeConstants.sleepDelay {
                state.isSleeping = true
                state.timestamps.lightsOffAt = nil
            }
        } else {
            state.timestamps.lightsOffAt = now
        }

        return state
    }
}
