import Foundation

nonisolated enum StepBonusCalculator {
    /// 1 bonus meal per 1000 steps
    static let stepsPerBonus = 1000

    /// Calculate how many bonus feedings the user has earned
    static func bonusMeals(from steps: Int) -> Int {
        max(0, steps / stepsPerBonus)
    }
}
