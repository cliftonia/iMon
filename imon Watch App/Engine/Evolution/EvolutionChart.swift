import Foundation

// swiftlint:disable function_body_length

nonisolated enum EvolutionChart {

    // MARK: - Complete V1 Evolution Tree

    static let requirements: [EvolutionRequirement] = buildRequirements()

    /// Get possible evolutions for a species
    static func evolutions(
        for species: virtual petSpecies
    ) -> [EvolutionRequirement] {
        requirements.filter { $0.from == species }
    }

    // MARK: - Private

    private static func buildRequirements() -> [EvolutionRequirement] {
        var chart: [EvolutionRequirement] = []

        // Fresh -> In-Training (always after 1 hour)
        chart.append(
            EvolutionRequirement(
                from: .dotkin,
                to: .hopkin,
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
        chart.append(contentsOf: hopkinPaths())

        // Rookie -> Champion (after 24 hours)
        chart.append(contentsOf: emberkinPaths())
        chart.append(contentsOf: marshkinPaths())

        // Champion -> Ultimate (after 36 hours)
        chart.append(contentsOf: championPaths())

        return chart
    }

    // MARK: - In-Training Paths

    private static func hopkinPaths() -> [EvolutionRequirement] {
        [
            // 0-1 care mistakes -> Emberkin
            EvolutionRequirement(
                from: .hopkin,
                to: .emberkin,
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
            // 2+ care mistakes -> Marshkin (default)
            EvolutionRequirement(
                from: .hopkin,
                to: .marshkin,
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

    // MARK: - Emberkin Paths

    private static func emberkinPaths() -> [EvolutionRequirement] {
        let time = TimeConstants.championEvolutionTime
        return [
            // 0-2 CM, 5+ wins -> Rexkin
            EvolutionRequirement(
                from: .emberkin, to: .rexkin,
                minAwakeTime: time,
                maxCareMistakes: 2, minCareMistakes: nil,
                minBattleWins: 5, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: false
            ),
            // 4+ CM, overfeed (weight 40+) -> Blazekin
            EvolutionRequirement(
                from: .emberkin, to: .blazekin,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: 4,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: 40,
                isDefault: false
            ),
            // 0-3 CM, low training -> Dreadkin
            EvolutionRequirement(
                from: .emberkin, to: .dreadkin,
                minAwakeTime: time,
                maxCareMistakes: 3, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: false
            ),
            // 4+ CM, train 16+ -> Pyrekin
            EvolutionRequirement(
                from: .emberkin, to: .pyrekin,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: 4,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: 16,
                maxWeight: nil, minWeight: nil,
                isDefault: false
            ),
            // Default -> Sludgekin
            EvolutionRequirement(
                from: .emberkin, to: .sludgekin,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
        ]
    }

    // MARK: - Marshkin Paths

    private static func marshkinPaths() -> [EvolutionRequirement] {
        let time = TimeConstants.championEvolutionTime
        return [
            // 0-3 CM, train 48+ -> Dreadkin
            EvolutionRequirement(
                from: .marshkin, to: .dreadkin,
                minAwakeTime: time,
                maxCareMistakes: 3, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: 48,
                maxWeight: nil, minWeight: nil,
                isDefault: false
            ),
            // 4+ CM -> Galekin
            EvolutionRequirement(
                from: .marshkin, to: .galekin,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: 4,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: false
            ),
            // 4+ CM, weight 35+ -> Tidekin
            EvolutionRequirement(
                from: .marshkin, to: .tidekin,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: 4,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: 35,
                isDefault: false
            ),
            // Default -> Sludgekin
            EvolutionRequirement(
                from: .marshkin, to: .sludgekin,
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
            // Rexkin -> Steelkin (15+ battles, 80%+ win rate)
            EvolutionRequirement(
                from: .rexkin, to: .steelkin,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: 15, minWinRate: 0.8,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
            // Blazekin -> Orbkin
            EvolutionRequirement(
                from: .blazekin, to: .orbkin,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
            // Dreadkin -> Steelkin
            EvolutionRequirement(
                from: .dreadkin, to: .steelkin,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
            // Pyrekin -> Orbkin
            EvolutionRequirement(
                from: .pyrekin, to: .orbkin,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
            // Galekin -> Steelkin
            EvolutionRequirement(
                from: .galekin, to: .steelkin,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
            // Tidekin -> Orbkin
            EvolutionRequirement(
                from: .tidekin, to: .orbkin,
                minAwakeTime: time,
                maxCareMistakes: nil, minCareMistakes: nil,
                minBattleWins: nil, minWinRate: nil,
                minTrainingCount: nil,
                maxWeight: nil, minWeight: nil,
                isDefault: true
            ),
            // Sludgekin -> Plushkin
            EvolutionRequirement(
                from: .sludgekin, to: .plushkin,
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
