import Foundation

nonisolated struct PetState: Sendable {

    // MARK: - Identity

    let id: Tagged<PetState, UUID>
    var species: PetSpecies

    // MARK: - Vital Stats

    var hungerHearts: StatHearts = .full
    var strengthHearts: StatHearts = .full
    var weight: Weight = Weight(10)
    var age: Int = 0
    var poopCount: Int = 0
    var isSleeping: Bool = false
    var lightsOn: Bool = true

    // MARK: - Health

    var isInjured: Bool = false
    var injuryCount: Int = 0
    var careMistakes: Int = 0

    // MARK: - Records

    var battleWins: Int = 0
    var battleLosses: Int = 0
    var trainingCount: Int = 0

    // MARK: - Lifecycle

    var isDead: Bool = false
    var isEgg: Bool = false

    // MARK: - Timestamps

    var timestamps: Timestamps
}

// MARK: - Timestamps

extension PetState {

    /// Every event timestamp for the pet, grouped together. Elapsed timers are
    /// non-optional; one-off / pending events are optional.
    nonisolated struct Timestamps: Sendable {
        var bornAt: Date
        var lastFedAt: Date
        var lastTrainedAt: Date
        var lastPoopAt: Date
        var lastHungerDecayAt: Date
        var lastStrengthDecayAt: Date
        var evolvedAt: Date
        var lastAdvancedAt: Date
        var injuredAt: Date?
        var pendingCareMistakeAt: Date?
        var pendingLightsMistakeAt: Date?
        var lightsToggledDuringSleepAt: Date?

        /// A freshly created pet: every elapsed timer starts at `date`, with no
        /// pending events outstanding.
        init(creating date: Date) {
            bornAt = date
            lastFedAt = date
            lastTrainedAt = date
            lastPoopAt = date
            lastHungerDecayAt = date
            lastStrengthDecayAt = date
            evolvedAt = date
            lastAdvancedAt = date
            injuredAt = nil
            pendingCareMistakeAt = nil
            pendingLightsMistakeAt = nil
            lightsToggledDuringSleepAt = nil
        }

        // Full memberwise init (a custom init above suppresses the synthesised one).
        init(
            bornAt: Date,
            lastFedAt: Date,
            lastTrainedAt: Date,
            lastPoopAt: Date,
            lastHungerDecayAt: Date,
            lastStrengthDecayAt: Date,
            evolvedAt: Date,
            lastAdvancedAt: Date,
            injuredAt: Date?,
            pendingCareMistakeAt: Date?,
            pendingLightsMistakeAt: Date?,
            lightsToggledDuringSleepAt: Date?
        ) {
            self.bornAt = bornAt
            self.lastFedAt = lastFedAt
            self.lastTrainedAt = lastTrainedAt
            self.lastPoopAt = lastPoopAt
            self.lastHungerDecayAt = lastHungerDecayAt
            self.lastStrengthDecayAt = lastStrengthDecayAt
            self.evolvedAt = evolvedAt
            self.lastAdvancedAt = lastAdvancedAt
            self.injuredAt = injuredAt
            self.pendingCareMistakeAt = pendingCareMistakeAt
            self.pendingLightsMistakeAt = pendingLightsMistakeAt
            self.lightsToggledDuringSleepAt = lightsToggledDuringSleepAt
        }
    }
}

// MARK: - Factory

extension PetState {

    static func newEgg(at date: Date = .now) -> PetState {
        PetState(
            id: Tagged(rawValue: UUID()),
            species: .dotkin,
            weight: Weight(5),
            isEgg: true,
            timestamps: Timestamps(creating: date)
        )
    }

    static func hatched(at date: Date = .now) -> PetState {
        PetState(
            id: Tagged(rawValue: UUID()),
            species: .dotkin,
            timestamps: Timestamps(creating: date)
        )
    }
}
