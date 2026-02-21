import Foundation

nonisolated struct BattleOpponent: Sendable {

    let species: DigimonSpecies
    let power: Double
    let attribute: Attribute

    /// Generate an opponent matched to the player's current stage.
    /// Picks a random species of the same evolution stage.
    static func generate(matching state: PetState) -> BattleOpponent {
        let sameStage = DigimonSpecies.allCases.filter {
            $0.stage == state.species.stage && $0 != state.species
        }
        let opponent = sameStage.randomElement() ?? state.species
        let power = Double(opponent.basePower) + Double.random(in: -10...10)
        return BattleOpponent(
            species: opponent,
            power: max(1, power),
            attribute: opponent.attribute
        )
    }
}
