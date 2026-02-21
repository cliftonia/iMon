import Foundation

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
                from: .botamon, to: .koromon,
                minAwakeTime: TimeConstants.babyEvolutionTime,
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
        let time = TimeConstants.rookieEvolutionTime
        return [
            // 0-1 care mistakes -> Agumon
            EvolutionRequirement(
                from: .koromon, to: .agumon,
                minAwakeTime: time, maxCareMistakes: 1
            ),
            // 2+ care mistakes -> Betamon (default)
            EvolutionRequirement(
                from: .koromon, to: .betamon,
                minAwakeTime: time, minCareMistakes: 2,
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
                maxCareMistakes: 2, minBattleWins: 5
            ),
            // 4+ CM, overfeed (weight 40+) -> Tyrannomon
            EvolutionRequirement(
                from: .agumon, to: .tyrannomon,
                minAwakeTime: time,
                minCareMistakes: 4, minWeight: 40
            ),
            // 0-3 CM, low training -> Devimon
            EvolutionRequirement(
                from: .agumon, to: .devimon,
                minAwakeTime: time, maxCareMistakes: 3
            ),
            // 4+ CM, train 16+ -> Meramon
            EvolutionRequirement(
                from: .agumon, to: .meramon,
                minAwakeTime: time,
                minCareMistakes: 4, minTrainingCount: 16
            ),
            // Default -> Numemon
            EvolutionRequirement(
                from: .agumon, to: .numemon,
                minAwakeTime: time, isDefault: true
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
                maxCareMistakes: 3, minTrainingCount: 48
            ),
            // 4+ CM -> Airdramon
            EvolutionRequirement(
                from: .betamon, to: .airdramon,
                minAwakeTime: time, minCareMistakes: 4
            ),
            // 4+ CM, weight 35+ -> Seadramon
            EvolutionRequirement(
                from: .betamon, to: .seadramon,
                minAwakeTime: time,
                minCareMistakes: 4, minWeight: 35
            ),
            // Default -> Numemon
            EvolutionRequirement(
                from: .betamon, to: .numemon,
                minAwakeTime: time, isDefault: true
            ),
        ]
    }

    // MARK: - Champion Paths

    private static func championPaths() -> [EvolutionRequirement] {
        let time = TimeConstants.ultimateEvolutionTime
        return [
            EvolutionRequirement(
                from: .greymon, to: .metalGreymon,
                minAwakeTime: time,
                minBattleWins: 15, minWinRate: 0.8,
                isDefault: true
            ),
            EvolutionRequirement(
                from: .tyrannomon, to: .mamemon,
                minAwakeTime: time, isDefault: true
            ),
            EvolutionRequirement(
                from: .devimon, to: .metalGreymon,
                minAwakeTime: time, isDefault: true
            ),
            EvolutionRequirement(
                from: .meramon, to: .mamemon,
                minAwakeTime: time, isDefault: true
            ),
            EvolutionRequirement(
                from: .airdramon, to: .metalGreymon,
                minAwakeTime: time, isDefault: true
            ),
            EvolutionRequirement(
                from: .seadramon, to: .mamemon,
                minAwakeTime: time, isDefault: true
            ),
            EvolutionRequirement(
                from: .numemon, to: .monzaemon,
                minAwakeTime: time, isDefault: true
            ),
        ]
    }
}
