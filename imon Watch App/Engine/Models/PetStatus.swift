import Foundation

nonisolated struct PetStatus: Sendable {
    let species: DigimonSpecies
    let stage: EvolutionStage
    let hungerHearts: StatHearts
    let strengthHearts: StatHearts
    let weightGrams: Int
    let ageDays: Int
    let poopCount: Int
    let isSleeping: Bool
    let lightsOn: Bool
    let isInjured: Bool
    let isDead: Bool
    let isEgg: Bool
    let battleWins: Int
    let battleLosses: Int
    let needsAttention: Bool

    init(from state: PetState) {
        species = state.species
        stage = state.species.stage
        hungerHearts = state.hungerHearts
        strengthHearts = state.strengthHearts
        weightGrams = state.weight.grams
        ageDays = state.age
        poopCount = state.poopCount
        isSleeping = state.isSleeping
        lightsOn = state.lightsOn
        isInjured = state.isInjured
        isDead = state.isDead
        isEgg = state.isEgg
        battleWins = state.battleWins
        battleLosses = state.battleLosses
        needsAttention = state.hungerHearts.isEmpty
            || state.strengthHearts.isEmpty
            || state.poopCount > 0
            || state.isInjured
    }
}
