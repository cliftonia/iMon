import Foundation

/// Maps the wearer's real-world activity (today's step count) into the
/// multipliers that shape the pet's metabolism, combat and health.
///
/// More movement → hungrier (eat more) but stronger and a fitter fighter.
/// Less movement → less hungry but weaker (more vitamins) and injury-prone.
/// All tuning lives here; every value is clamped so depletion never stops.
nonisolated enum ActivityModel {

    /// Daily steps that count as "fully active" (factor reaches 1.0).
    static let stepGoal = 8_000

    /// Below this activity factor the pet is treated as sedentary.
    static let sedentaryFactor = 0.25

    /// 0 (sedentary) … 1 (very active).
    static func factor(steps: Int) -> Double {
        min(1, max(0, Double(steps) / Double(stepGoal)))
    }

    static func isSedentary(steps: Int) -> Bool {
        factor(steps: steps) < sedentaryFactor
    }

    /// Hunger depletes faster the more you move (×0.8 still → ×1.5 active).
    static func hungerRateMultiplier(steps: Int) -> Double {
        0.8 + 0.7 * factor(steps: steps)
    }

    /// Strength depletes faster the less you move (×1.5 still → ×0.8 active).
    static func strengthRateMultiplier(steps: Int) -> Double {
        1.5 - 0.7 * factor(steps: steps)
    }

    // AUDIT 2026-06-24: unused in production — the active-fitness battle bonus
    // lives in `BattleHP`. Referenced only by tests. Keep or remove.
    /// Battle power scales up with activity (×0.85 still → ×1.15 active).
    static func battlePowerMultiplier(steps: Int) -> Double {
        0.85 + 0.3 * factor(steps: steps)
    }
}
