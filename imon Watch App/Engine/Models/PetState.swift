import Foundation

nonisolated struct PetState: Codable, Sendable {

    // MARK: - Identity

    let id: Tagged<PetState, UUID>
    var species: DigimonSpecies

    // MARK: - Vital Stats

    var hungerHearts: StatHearts
    var strengthHearts: StatHearts
    var weight: Weight
    var age: Int
    var poopCount: Int
    var isSleeping: Bool
    var lightsOn: Bool

    // MARK: - Health

    var isInjured: Bool
    var injuryCount: Int
    var careMistakes: Int

    // MARK: - Records

    var battleWins: Int
    var battleLosses: Int
    var trainingCount: Int

    // MARK: - Lifecycle

    var isDead: Bool
    var isEgg: Bool

    // MARK: - Timestamps

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
    var lightsToggledDuringSleepAt: Date?
    var lastAdvancedAt: Date
}

// MARK: - Factory

extension PetState {
    static func newEgg(at date: Date = .now) -> PetState {
        PetState(
            id: Tagged<PetState, UUID>(rawValue: UUID()),
            species: .botamon,
            hungerHearts: .full,
            strengthHearts: .full,
            weight: Weight(5),
            age: 0,
            poopCount: 0,
            isSleeping: false,
            lightsOn: true,
            isInjured: false,
            injuryCount: 0,
            careMistakes: 0,
            battleWins: 0,
            battleLosses: 0,
            trainingCount: 0,
            isDead: false,
            isEgg: true,
            bornAt: date,
            lastFedAt: date,
            lastTrainedAt: date,
            lastPoopAt: date,
            lastHungerDecayAt: date,
            lastStrengthDecayAt: date,
            evolvedAt: date,
            injuredAt: nil,
            pendingCareMistakeAt: nil,
            pendingLightsMistakeAt: nil,
            lightsToggledDuringSleepAt: nil,
            lastAdvancedAt: date
        )
    }

    static func hatched(at date: Date = .now) -> PetState {
        PetState(
            id: Tagged<PetState, UUID>(rawValue: UUID()),
            species: .botamon,
            hungerHearts: .full,
            strengthHearts: .full,
            weight: Weight(10),
            age: 0,
            poopCount: 0,
            isSleeping: false,
            lightsOn: true,
            isInjured: false,
            injuryCount: 0,
            careMistakes: 0,
            battleWins: 0,
            battleLosses: 0,
            trainingCount: 0,
            isDead: false,
            isEgg: false,
            bornAt: date,
            lastFedAt: date,
            lastTrainedAt: date,
            lastPoopAt: date,
            lastHungerDecayAt: date,
            lastStrengthDecayAt: date,
            evolvedAt: date,
            injuredAt: nil,
            pendingCareMistakeAt: nil,
            pendingLightsMistakeAt: nil,
            lightsToggledDuringSleepAt: nil,
            lastAdvancedAt: date
        )
    }
}
