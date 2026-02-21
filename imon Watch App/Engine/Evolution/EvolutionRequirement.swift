import Foundation

nonisolated struct EvolutionRequirement: Sendable {

    let from: DigimonSpecies
    let to: DigimonSpecies
    let minAwakeTime: TimeInterval
    let maxCareMistakes: Int?
    let minCareMistakes: Int?
    let minBattleWins: Int?
    let minWinRate: Double?
    let minTrainingCount: Int?
    let maxWeight: Int?
    let minWeight: Int?
    let isDefault: Bool

    // MARK: - Evaluation

    func isSatisfied(by state: PetState, at now: Date) -> Bool {
        let awakeTime = now.timeIntervalSince(state.evolvedAt)
        guard awakeTime >= minAwakeTime else { return false }

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
        if let maxW = maxWeight, state.weight.grams > maxW { return false }
        if let minW = minWeight, state.weight.grams < minW { return false }

        return true
    }
}
