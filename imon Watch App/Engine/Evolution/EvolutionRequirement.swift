import Foundation

/// One row of the `EvolutionChart`: a from→to edge plus the care gates that
/// select it. A `nil` gate is unconstrained; `isDefault` marks the fallback
/// row taken only when no specific row matches.
nonisolated struct EvolutionRequirement: Sendable {

    let from: PetSpecies
    let to: PetSpecies
    let maxCareMistakes: Int?
    let minCareMistakes: Int?
    let minBattleWins: Int?
    let minWinRate: Double?
    let minTrainingCount: Int?
    let minWeight: Int?
    let isDefault: Bool

    init(
        from: PetSpecies,
        to: PetSpecies,
        maxCareMistakes: Int? = nil,
        minCareMistakes: Int? = nil,
        minBattleWins: Int? = nil,
        minWinRate: Double? = nil,
        minTrainingCount: Int? = nil,
        minWeight: Int? = nil,
        isDefault: Bool = false
    ) {
        self.from = from
        self.to = to
        self.maxCareMistakes = maxCareMistakes
        self.minCareMistakes = minCareMistakes
        self.minBattleWins = minBattleWins
        self.minWinRate = minWinRate
        self.minTrainingCount = minTrainingCount
        self.minWeight = minWeight
        self.isDefault = isDefault
    }

    // MARK: - Evaluation

    /// Steps gate *when* (the lifetime accumulator must reach the stage
    /// threshold, raised by any lazy-day penalty); the care fields below decide
    /// *which* branch.
    func isSatisfied(by state: PetState) -> Bool {
        guard state.lifetimeActiveSteps >= state.evolutionGoal else {
            return false
        }

        if let max = maxCareMistakes, state.careMistakes > max { return false }
        if let min = minCareMistakes, state.careMistakes < min { return false }
        if let wins = minBattleWins, state.battleWins < wins { return false }

        if let rate = minWinRate {
            let total = state.battleWins + state.battleLosses
            guard total > 0 else { return false }
            let winRate = Double(state.battleWins) / Double(total)
            if winRate < rate { return false }
        }

        if let train = minTrainingCount, state.trainingCount < train { return false }
        if let minW = minWeight, state.weight.grams < minW { return false }

        return true
    }
}
