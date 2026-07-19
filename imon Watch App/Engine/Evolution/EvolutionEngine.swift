import Foundation
import os

/// Chooses the pet's next species from the `EvolutionChart`: any satisfied
/// specific row beats the default row, and chart order breaks ties between
/// specific rows.
nonisolated enum EvolutionEngine {

    static func checkEvolution(for state: PetState) -> PetSpecies? {
        guard !state.isEgg, state.species.stage != .ultimate else { return nil }

        let candidates = EvolutionChart.evolutions(for: state.species)

        let specific = candidates.filter {
            !$0.isDefault && $0.isSatisfied(by: state)
        }
        if let best = specific.first {
            return best.to
        }

        let defaults = candidates.filter {
            $0.isDefault && $0.isSatisfied(by: state)
        }
        return defaults.first?.to
    }

    /// Applies evolution to state, resetting stage-specific counters.
    static func evolve(
        _ state: PetState,
        to species: PetSpecies,
        at now: Date
    ) -> PetState {
        var state = state
        state.species = species
        state.weight = Weight(species.baseWeight)
        state.timestamps.evolvedAt = now
        state.hungerHearts = StatHearts(species.maxHunger)
        state.strengthHearts = StatHearts(species.maxStrength)
        state.careMistakes = 0
        state.battleWins = 0
        state.battleLosses = 0
        state.trainingCount = 0
        // Fresh stage, fresh goal — lazy penalties don't follow the pet across stages.
        state.evolutionGoalPenalty = 0
        // injuryCount resets too — carried over, training injuries kill in ~40 days.
        state.timestamps.collapsingAt = nil
        state.isInjured = false
        state.timestamps.injuredAt = nil
        state.injuryCount = 0
        state.poopCount = 0
        Log.engine.info("Evolved to \(species.displayName)")
        return state
    }
}
