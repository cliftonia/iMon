import Foundation
import os

/// Core simulation loop that advances pet state from `lastAdvancedAt` to a
/// given point in time. Called on app wake, timer tick, and user actions.
nonisolated enum GameEngine {

    /// Advance the full game state to the supplied date, running every
    /// simulator in the correct order and checking death conditions.
    ///
    /// `isNight` is the weather's daylight reading; `nil` falls back to the
    /// fixed clock window in `SleepSchedule.isNight`. `steps` is today's
    /// running step count; `nil` (steps disabled or unavailable) leaves every
    /// simulator at its base, activity-unscaled rate.
    static func advance(
        _ state: PetState,
        to now: Date,
        isNight: Bool? = nil,
        steps: Int? = nil
    ) -> PetState {
        var state = state

        guard !state.isDead, !state.isEgg else {
            state.timestamps.lastAdvancedAt = now
            return state
        }

        // Clamped so a backward clock can't produce a negative age.
        let days = Calendar.current.dateComponents(
            [.day], from: state.timestamps.bornAt, to: now
        ).day ?? state.age
        state.age = max(0, days)

        // Resolve day/night and bedtime once so every simulator sees the same signal.
        let night = SleepSchedule.isNight(weatherNight: isNight, at: now)
        let bedtime = SleepSchedule.isBedtime(at: now)

        // Apply simulators in dependency order
        state = SleepSchedule.apply(to: state, at: now, night: night)
        state = HungerSimulator.apply(to: state, at: now, steps: steps)
        state = StrengthSimulator.apply(to: state, at: now, steps: steps)
        state = ConditioningSimulator.apply(to: state, at: now)
        state = PoopSimulator.apply(to: state, at: now)
        state = InjurySimulator.apply(to: state, at: now, steps: steps)
        state = CareMistakeTracker.apply(to: state, at: now, bedtime: bedtime)
        state = CollapseTracker.apply(to: state, at: now)

        if let cause = DeathEvaluator.evaluate(state, at: now) {
            Log.engine.info("Pet died from \(String(describing: cause))")
            state = DeathEvaluator.applyDeath(to: state)
        }

        state.timestamps.lastAdvancedAt = now
        return state
    }
}
