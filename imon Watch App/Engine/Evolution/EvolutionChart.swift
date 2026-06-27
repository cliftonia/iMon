import Foundation

nonisolated enum EvolutionChart {

    // MARK: - Complete Evolution Tree

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

        // Fresh -> In-Training (always, once the step gate is met)
        chart.append(
            EvolutionRequirement(from: .dotkin, to: .hopkin, isDefault: true)
        )

        // In-Training -> Rookie
        chart.append(contentsOf: hopkinPaths())

        // Rookie -> Champion
        chart.append(contentsOf: emberkinPaths())
        chart.append(contentsOf: marshkinPaths())

        // Champion -> Ultimate
        chart.append(contentsOf: championPaths())

        return chart
    }

    // MARK: - In-Training Paths

    private static func hopkinPaths() -> [EvolutionRequirement] {
        [
            // 0-1 care mistakes -> Emberkin
            EvolutionRequirement(
                from: .hopkin, to: .emberkin, maxCareMistakes: 1
            ),
            // 2+ care mistakes -> Marshkin (default)
            EvolutionRequirement(
                from: .hopkin, to: .marshkin,
                minCareMistakes: 2, isDefault: true
            ),
        ]
    }

    // MARK: - Emberkin Paths

    private static func emberkinPaths() -> [EvolutionRequirement] {
        [
            // 0-2 CM, 5+ wins -> Rexkin
            EvolutionRequirement(
                from: .emberkin, to: .rexkin,
                maxCareMistakes: 2, minBattleWins: 5
            ),
            // 4+ CM, overfeed (weight 40+) -> Blazekin
            EvolutionRequirement(
                from: .emberkin, to: .blazekin,
                minCareMistakes: 4, minWeight: 40
            ),
            // 0-3 CM, low training -> Dreadkin
            EvolutionRequirement(
                from: .emberkin, to: .dreadkin, maxCareMistakes: 3
            ),
            // 4+ CM, train 16+ -> Pyrekin
            EvolutionRequirement(
                from: .emberkin, to: .pyrekin,
                minCareMistakes: 4, minTrainingCount: 16
            ),
            // Default -> Sludgekin
            EvolutionRequirement(
                from: .emberkin, to: .sludgekin, isDefault: true
            ),
        ]
    }

    // MARK: - Marshkin Paths

    private static func marshkinPaths() -> [EvolutionRequirement] {
        [
            // 0-3 CM, train 48+ -> Dreadkin
            EvolutionRequirement(
                from: .marshkin, to: .dreadkin,
                maxCareMistakes: 3, minTrainingCount: 48
            ),
            // 4+ CM, weight 35+ -> Tidekin. Must precede Galekin: it's the more
            // specific gate, so first-match would otherwise shadow it away.
            EvolutionRequirement(
                from: .marshkin, to: .tidekin,
                minCareMistakes: 4, minWeight: 35
            ),
            // 4+ CM (lighter) -> Galekin
            EvolutionRequirement(
                from: .marshkin, to: .galekin, minCareMistakes: 4
            ),
            // Default -> Sludgekin
            EvolutionRequirement(
                from: .marshkin, to: .sludgekin, isDefault: true
            ),
        ]
    }

    // MARK: - Champion Paths

    private static func championPaths() -> [EvolutionRequirement] {
        [
            EvolutionRequirement(
                from: .rexkin, to: .steelkin,
                minBattleWins: 15, minWinRate: 0.8, isDefault: true
            ),
            EvolutionRequirement(
                from: .blazekin, to: .orbkin, isDefault: true
            ),
            EvolutionRequirement(
                from: .dreadkin, to: .steelkin, isDefault: true
            ),
            EvolutionRequirement(
                from: .pyrekin, to: .orbkin, isDefault: true
            ),
            EvolutionRequirement(
                from: .galekin, to: .steelkin, isDefault: true
            ),
            EvolutionRequirement(
                from: .tidekin, to: .orbkin, isDefault: true
            ),
            EvolutionRequirement(
                from: .sludgekin, to: .plushkin, isDefault: true
            ),
        ]
    }
}
