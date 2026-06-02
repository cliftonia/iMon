import Foundation

nonisolated enum EvolutionChart {

    // MARK: - Complete V1 Evolution Tree

    static let requirements: [EvolutionRequirement] = buildRequirements()

    /// Get possible evolutions for a species
    static func evolutions(
        for species: PetSpecies
    ) -> [EvolutionRequirement] {
        requirements.filter { $0.from == species }
    }

    // MARK: - Private

    private static func buildRequirements() -> [EvolutionRequirement] {
        var chart: [EvolutionRequirement] = []

        // Fresh -> In-Training (always after 1 hour)
        chart.append(
            EvolutionRequirement(
                from: .dotkin, to: .hopkin,
                minAwakeTime: TimeConstants.babyEvolutionTime,
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
        let time = TimeConstants.rookieEvolutionTime
        return [
            // 0-1 care mistakes -> Emberkin
            EvolutionRequirement(
                from: .hopkin, to: .emberkin,
                minAwakeTime: time, maxCareMistakes: 1
            ),
            // 2+ care mistakes -> Marshkin (default)
            EvolutionRequirement(
                from: .hopkin, to: .marshkin,
                minAwakeTime: time, minCareMistakes: 2,
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
                maxCareMistakes: 2, minBattleWins: 5
            ),
            // 4+ CM, overfeed (weight 40+) -> Blazekin
            EvolutionRequirement(
                from: .emberkin, to: .blazekin,
                minAwakeTime: time,
                minCareMistakes: 4, minWeight: 40
            ),
            // 0-3 CM, low training -> Dreadkin
            EvolutionRequirement(
                from: .emberkin, to: .dreadkin,
                minAwakeTime: time, maxCareMistakes: 3
            ),
            // 4+ CM, train 16+ -> Pyrekin
            EvolutionRequirement(
                from: .emberkin, to: .pyrekin,
                minAwakeTime: time,
                minCareMistakes: 4, minTrainingCount: 16
            ),
            // Default -> Sludgekin
            EvolutionRequirement(
                from: .emberkin, to: .sludgekin,
                minAwakeTime: time, isDefault: true
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
                maxCareMistakes: 3, minTrainingCount: 48
            ),
            // 4+ CM -> Galekin
            EvolutionRequirement(
                from: .marshkin, to: .galekin,
                minAwakeTime: time, minCareMistakes: 4
            ),
            // 4+ CM, weight 35+ -> Tidekin
            EvolutionRequirement(
                from: .marshkin, to: .tidekin,
                minAwakeTime: time,
                minCareMistakes: 4, minWeight: 35
            ),
            // Default -> Sludgekin
            EvolutionRequirement(
                from: .marshkin, to: .sludgekin,
                minAwakeTime: time, isDefault: true
            ),
        ]
    }

    // MARK: - Champion Paths

    private static func championPaths() -> [EvolutionRequirement] {
        let time = TimeConstants.ultimateEvolutionTime
        return [
            EvolutionRequirement(
                from: .rexkin, to: .steelkin,
                minAwakeTime: time,
                minBattleWins: 15, minWinRate: 0.8,
                isDefault: true
            ),
            EvolutionRequirement(
                from: .blazekin, to: .orbkin,
                minAwakeTime: time, isDefault: true
            ),
            EvolutionRequirement(
                from: .dreadkin, to: .steelkin,
                minAwakeTime: time, isDefault: true
            ),
            EvolutionRequirement(
                from: .pyrekin, to: .orbkin,
                minAwakeTime: time, isDefault: true
            ),
            EvolutionRequirement(
                from: .galekin, to: .steelkin,
                minAwakeTime: time, isDefault: true
            ),
            EvolutionRequirement(
                from: .tidekin, to: .orbkin,
                minAwakeTime: time, isDefault: true
            ),
            EvolutionRequirement(
                from: .sludgekin, to: .plushkin,
                minAwakeTime: time, isDefault: true
            ),
        ]
    }
}
