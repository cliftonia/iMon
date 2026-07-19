import Foundation

/// On-disk representation of `PetState`.
///
/// Deliberately **flat and stable** so the domain model can be regrouped or
/// extended without breaking saved pets — only the mapping below changes.
/// `schemaVersion` is optional so pre-versioning saves still decode (nil = v1),
/// and is the hook for future migrations.
nonisolated struct PetStateDTO: Codable, Sendable {

    static let currentVersion = 2

    var schemaVersion: Int?

    var id: Tagged<PetState, UUID>
    var species: PetSpecies

    var hungerHearts: StatHearts
    var strengthHearts: StatHearts
    var weight: Weight
    var age: Int
    var poopCount: Int
    var isSleeping: Bool
    var lightsOn: Bool

    var isInjured: Bool
    var injuryCount: Int
    var careMistakes: Int

    var battleWins: Int
    var battleLosses: Int
    var trainingCount: Int

    var trainedHP: Int?
    var trainedPower: Int?

    var lifetimeActiveSteps: Int?
    var stepsCreditedToday: Int?
    var stepTrackedDay: Date?
    var evolutionGoalPenalty: Int?

    var isDead: Bool
    var isEgg: Bool
    var wasNight: Bool?

    var bornAt: Date
    var lastFedAt: Date
    var lastTrainedAt: Date
    var lastPoopAt: Date
    var lastHungerDecayAt: Date
    var lastStrengthDecayAt: Date
    var evolvedAt: Date
    var injuredAt: Date?
    var pendingCareMistakeAt: Date?
    var pendingLightsMistakeAt: Date?
    var lightsOffAt: Date?
    var collapsingAt: Date?
    var lastAdvancedAt: Date
    var lastBattledAt: Date?
}

// MARK: - Mapping

nonisolated extension PetStateDTO {
    /// Flattens a domain `PetState` into its storable form.
    init(from state: PetState) {
        let times = state.timestamps
        schemaVersion = Self.currentVersion
        id = state.id
        species = state.species
        hungerHearts = state.hungerHearts
        strengthHearts = state.strengthHearts
        weight = state.weight
        age = state.age
        poopCount = state.poopCount
        isSleeping = state.isSleeping
        lightsOn = state.lightsOn
        isInjured = state.isInjured
        injuryCount = state.injuryCount
        careMistakes = state.careMistakes
        battleWins = state.battleWins
        battleLosses = state.battleLosses
        trainingCount = state.trainingCount
        trainedHP = state.trainedHP
        trainedPower = state.trainedPower
        lifetimeActiveSteps = state.lifetimeActiveSteps
        stepsCreditedToday = state.stepsCreditedToday
        stepTrackedDay = state.stepTrackedDay
        evolutionGoalPenalty = state.evolutionGoalPenalty
        isDead = state.isDead
        isEgg = state.isEgg
        wasNight = state.wasNight
        bornAt = times.bornAt
        lastFedAt = times.lastFedAt
        lastTrainedAt = times.lastTrainedAt
        lastPoopAt = times.lastPoopAt
        lastHungerDecayAt = times.lastHungerDecayAt
        lastStrengthDecayAt = times.lastStrengthDecayAt
        evolvedAt = times.evolvedAt
        injuredAt = times.injuredAt
        pendingCareMistakeAt = times.pendingCareMistakeAt
        pendingLightsMistakeAt = times.pendingLightsMistakeAt
        lightsOffAt = times.lightsOffAt
        collapsingAt = times.collapsingAt
        lastAdvancedAt = times.lastAdvancedAt
        lastBattledAt = times.lastBattledAt
    }
}

nonisolated extension PetState {
    /// Rebuilds a domain `PetState` from its stored form.
    init(from dto: PetStateDTO) {
        self.init(
            id: dto.id,
            species: dto.species,
            hungerHearts: dto.hungerHearts,
            strengthHearts: dto.strengthHearts,
            weight: dto.weight,
            age: dto.age,
            poopCount: dto.poopCount,
            isSleeping: dto.isSleeping,
            lightsOn: dto.lightsOn,
            isInjured: dto.isInjured,
            injuryCount: dto.injuryCount,
            careMistakes: dto.careMistakes,
            battleWins: dto.battleWins,
            battleLosses: dto.battleLosses,
            trainingCount: dto.trainingCount,
            trainedHP: dto.trainedHP ?? 0,
            trainedPower: dto.trainedPower ?? 0,
            lifetimeActiveSteps: dto.lifetimeActiveSteps ?? 0,
            stepsCreditedToday: dto.stepsCreditedToday ?? 0,
            stepTrackedDay: dto.stepTrackedDay,
            evolutionGoalPenalty: dto.evolutionGoalPenalty ?? 0,
            isDead: dto.isDead,
            isEgg: dto.isEgg,
            wasNight: dto.wasNight ?? false,
            timestamps: PetState.Timestamps(
                bornAt: dto.bornAt,
                lastFedAt: dto.lastFedAt,
                lastTrainedAt: dto.lastTrainedAt,
                lastPoopAt: dto.lastPoopAt,
                lastHungerDecayAt: dto.lastHungerDecayAt,
                lastStrengthDecayAt: dto.lastStrengthDecayAt,
                evolvedAt: dto.evolvedAt,
                lastAdvancedAt: dto.lastAdvancedAt,
                lastBattledAt: dto.lastBattledAt ?? dto.bornAt,
                injuredAt: dto.injuredAt,
                pendingCareMistakeAt: dto.pendingCareMistakeAt,
                pendingLightsMistakeAt: dto.pendingLightsMistakeAt,
                lightsOffAt: dto.lightsOffAt,
                collapsingAt: dto.collapsingAt
            )
        )
    }
}
