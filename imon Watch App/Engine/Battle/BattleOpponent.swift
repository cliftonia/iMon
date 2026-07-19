import Foundation

/// A sparring partner drawn for a single battle: a species plus a power roll
/// jittered around the species base so repeat fights are not identical.
nonisolated struct BattleOpponent: Sendable {

    let species: PetSpecies
    let power: Double

    /// Generates an opponent matched to the player's current stage.
    /// Prefers a different species of the same evolution stage, falling
    /// back to any other species so the pet never battles itself.
    static func generate(matching state: PetState) -> BattleOpponent {
        let sameStage = PetSpecies.allCases.filter {
            $0.stage == state.species.stage && $0 != state.species
        }
        let others = PetSpecies.allCases.filter {
            $0 != state.species
        }
        let opponent = sameStage.randomElement()
            ?? others.randomElement()
            ?? state.species
        let power = Double(opponent.basePower) + Double.random(in: -10...10)
        return BattleOpponent(
            species: opponent,
            power: max(1, power)
        )
    }
}
