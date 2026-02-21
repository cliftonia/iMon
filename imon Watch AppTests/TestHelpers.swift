import Foundation
@testable import imon_Watch_App

func makeTestState(
    species: DigimonSpecies = .agumon,
    hunger: Int = 4,
    strength: Int = 4,
    weight: Int = 20,
    at date: Date = .now
) -> PetState {
    var state = PetState.hatched(at: date)
    state.species = species
    state.hungerHearts = StatHearts(hunger)
    state.strengthHearts = StatHearts(strength)
    state.weight = Weight(weight)
    return state
}
