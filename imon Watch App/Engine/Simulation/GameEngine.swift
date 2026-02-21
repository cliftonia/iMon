import Foundation
import os

/// Core simulation loop that advances pet state from `lastAdvancedAt` to a
/// given point in time. Called on app wake, timer tick, and user actions.
nonisolated enum GameEngine {

    /// Advance the full game state to the supplied date, running every
    /// simulator in the correct order and checking death conditions.
    static func advance(_ state: PetState, to now: Date) -> PetState {
        var state = state

        guard !state.isDead, !state.isEgg else {
            state.lastAdvancedAt = now
            return state
        }

        // Update age (whole days since birth)
        let calendar = Calendar.current
        state.age = calendar.dateComponents([.day], from: state.bornAt, to: now).day ?? state.age

        // Apply simulators in dependency order
        state = SleepSchedule.apply(to: state, at: now)
        state = HungerSimulator.apply(to: state, at: now)
        state = StrengthSimulator.apply(to: state, at: now)
        state = PoopSimulator.apply(to: state, at: now)
        state = InjurySimulator.apply(to: state, at: now)
        state = CareMistakeTracker.apply(to: state, at: now)

        // Evaluate death
        if let cause = DeathEvaluator.evaluate(state, at: now) {
            Log.engine.info("Pet died from \(String(describing: cause))")
            state = DeathEvaluator.applyDeath(to: state)
        }

        state.lastAdvancedAt = now
        return state
    }
}
