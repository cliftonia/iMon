import Foundation
import os

nonisolated enum EvolutionEngine {

    /// Check if the pet is ready to evolve and return the target species.
    /// Returns `nil` if no evolution is available.
    static func checkEvolution(
        for state: PetState,
        at now: Date
    ) -> DigimonSpecies? {
        guard state.species.stage != .ultimate else { return nil }

        let candidates = EvolutionChart.evolutions(for: state.species)

        // Try non-default requirements first (specific paths)
        let specific = candidates.filter {
            !$0.isDefault && $0.isSatisfied(by: state, at: now)
        }
        if let best = specific.first {
            return best.to
        }

        // Fall back to default path
        let defaults = candidates.filter {
            $0.isDefault && $0.isSatisfied(by: state, at: now)
        }
        return defaults.first?.to
    }

    /// Apply evolution to state, resetting stage-specific counters.
    static func evolve(
        _ state: PetState,
        to species: DigimonSpecies,
        at now: Date
    ) -> PetState {
        var state = state
        state.species = species
        state.weight = Weight(species.baseWeight)
        state.evolvedAt = now
        state.hungerHearts = .full
        state.strengthHearts = .full
        state.careMistakes = 0
        state.battleWins = 0
        state.battleLosses = 0
        state.trainingCount = 0
        Log.engine.info("Evolved to \(species.displayName)")
        return state
    }
}
