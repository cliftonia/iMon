import Foundation

// swiftlint:disable function_body_length

nonisolated enum EvolutionChart {

    // MARK: - Complete V1 Evolution Tree

    static let requirements: [EvolutionRequirement] = buildRequirements()

    /// Get possible evolutions for a species
    static func evolutions(
        for species: DigimonSpecies
    ) -> [EvolutionRequirement] {
        requirements.filter { $0.from == species }
    }

    // MARK: - Private

    private static func buildRequirements() -> [EvolutionRequirement] {
        var chart: [EvolutionRequirement] = []

        // Fresh -> In-Training (always after 1 hour)
        chart.append(
            EvolutionRequirement(
                from: .botamon,
                to: .koromon,
                minAwakeTime: TimeConstants.babyEvolutionTime,
                maxCareMistakes: nil,
                minCareMistakes: nil,
                minBattleWins: nil,
                minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil,
                minWeight: nil,
                isDefault: true
            )
        )

        // In-Training -> Rookie (after 6 hours)
        chart.append(contentsOf: koromonPaths())

        // Rookie -> Champion (after 24 hours)
        chart.append(contentsOf: agumonPaths())
        chart.append(contentsOf: betamonPaths())

        // Champion -> Ultimate (after 36 hours)
        chart.append(contentsOf: championPaths())

        return chart
    }

    // MARK: - In-Training Paths

    private static func koromonPaths() -> [EvolutionRequirement] {
        [
            // 0-1 care mistakes -> Agumon
            EvolutionRequirement(
                from: .koromon,
                to: .agumon,
                minAwakeTime: TimeConstants.rookieEvolutionTime,
                maxCareMistakes: 1,
                minCareMistakes: nil,
                minBattleWins: nil,
                minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil,
                minWeight: nil,
                isDefault: false
            ),
            // 2+ care mistakes -> Betamon (default)
            EvolutionRequirement(
                from: .koromon,
                to: .betamon,
                minAwakeTime: TimeConstants.rookieEvolutionTime,
                maxCareMistakes: nil,
                minCareMistakes: 2,
                minBattleWins: nil,
                minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil,
                minWeight: nil,
                isDefault: true
            ),
        ]
    }

    // MARK: - Agumon Paths

    private static func agumonPaths() -> [EvolutionRequirement] {
        let time = TimeConstants.championEvolutionTime
        return [
            // 0-2 CM, 5+ wins -> Greymon
            EvolutionRequirement(
                from: .agumon, to: .greymon,
                minAwakeTime: time,
                maxCareMistakes: 2, minCareMistakes: nil,
                minBattleWins: 5, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: false
            ),
            // 4+ CM, overfeed (weight 40+) -> Tyrannomon
            EvolutionRequirement(
                from: .agumon, to: .tyrannomon,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: 4,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: 40,
                isDefault: false
            ),
            // 0-3 CM, low training -> Devimon
            EvolutionRequirement(
                from: .agumon, to: .devimon,
                minAwakeTime: time,
                maxCareMistakes: 3, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: false
            ),
            // 4+ CM, train 16+ -> Meramon
            EvolutionRequirement(
                from: .agumon, to: .meramon,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: 4,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: 16,
                maxWeight: nil, minWeight: nil,
                isDefault: false
            ),
            // Default -> Numemon
            EvolutionRequirement(
                from: .agumon, to: .numemon,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
        ]
    }

    // MARK: - Betamon Paths

    private static func betamonPaths() -> [EvolutionRequirement] {
        let time = TimeConstants.championEvolutionTime
        return [
            // 0-3 CM, train 48+ -> Devimon
            EvolutionRequirement(
                from: .betamon, to: .devimon,
                minAwakeTime: time,
                maxCareMistakes: 3, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: 48,
                maxWeight: nil, minWeight: nil,
                isDefault: false
            ),
            // 4+ CM -> Airdramon
            EvolutionRequirement(
                from: .betamon, to: .airdramon,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: 4,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: false
            ),
            // 4+ CM, weight 35+ -> Seadramon
            EvolutionRequirement(
                from: .betamon, to: .seadramon,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: 4,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: 35,
                isDefault: false
            ),
            // Default -> Numemon
            EvolutionRequirement(
                from: .betamon, to: .numemon,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
        ]
    }

    // MARK: - Champion Paths

    private static func championPaths() -> [EvolutionRequirement] {
        let time = TimeConstants.ultimateEvolutionTime
        return [
            // Greymon -> MetalGreymon (15+ battles, 80%+ win rate)
            EvolutionRequirement(
                from: .greymon, to: .metalGreymon,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: 15, minWinRate: 0.8,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
            // Tyrannomon -> Mamemon
            EvolutionRequirement(
                from: .tyrannomon, to: .mamemon,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
            // Devimon -> MetalGreymon
            EvolutionRequirement(
                from: .devimon, to: .metalGreymon,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
            // Meramon -> Mamemon
            EvolutionRequirement(
                from: .meramon, to: .mamemon,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
            // Airdramon -> MetalGreymon
            EvolutionRequirement(
                from: .airdramon, to: .metalGreymon,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
            // Seadramon -> Mamemon
            EvolutionRequirement(
                from: .seadramon, to: .mamemon,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
            // Numemon -> Monzaemon
            EvolutionRequirement(
                from: .numemon, to: .monzaemon,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
        ]
    }
}

// swiftlint:enable function_body_length
