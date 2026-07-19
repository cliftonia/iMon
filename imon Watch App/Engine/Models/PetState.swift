import Foundation

/// The complete simulated state of one pet — the single value the engine's
/// pure `(PetState, Date) -> PetState` simulators advance. Deliberately not
/// `Codable`: saves go through the flat, versioned `PetStateDTO`, so this
/// model can be regrouped or extended without breaking stored pets.
nonisolated struct PetState: Sendable {

    // MARK: - Identity

    let id: Tagged<PetState, UUID>
    var species: PetSpecies

    // MARK: - Vital Stats

    var hungerHearts: StatHearts = .empty
    var strengthHearts: StatHearts = .empty
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

    // MARK: - Conditioning (trained combat bonuses, earned and lost through play)

    /// Bonus battle HP earned by training; decays toward zero when idle.
    var trainedHP: Int = 0
    /// Bonus battle power earned by winning; decays toward zero when idle.
    var trainedPower: Int = 0

    // MARK: - Fitness (step-driven growth)

    /// Lifetime active steps credited toward evolution (only ever grows).
    var lifetimeActiveSteps: Int = 0
    /// Today's steps already folded into `lifetimeActiveSteps`.
    var stepsCreditedToday: Int = 0
    /// The calendar day `stepsCreditedToday` belongs to; `nil` until first credit.
    var stepTrackedDay: Date?
    /// Extra steps added to the current stage's evolution goal by lazy days;
    /// reset to zero on each evolution.
    var evolutionGoalPenalty: Int = 0

    // MARK: - Lifecycle

    var isDead: Bool = false
    var isEgg: Bool = false

    /// Last-known day/night state, for detecting dusk/dawn transitions.
    var wasNight: Bool = false

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
        var lastBattledAt: Date
        var injuredAt: Date?
        var pendingCareMistakeAt: Date?
        var pendingLightsMistakeAt: Date?
        /// When the light was switched off at night — starts the sleep countdown.
        var lightsOffAt: Date?
        /// When the pet's hunger and strength both emptied — starts the collapse
        /// countdown toward death; cleared on recovery.
        var collapsingAt: Date?
        /// The moment each stat ran out, non-nil only while it is empty. The
        /// decay anchors keep advancing past empty, so the emptying moment
        /// cannot be recovered later — it is recorded as it happens, and gives
        /// `collapsingAt` its true start.
        var hungerEmptiedAt: Date?
        var strengthEmptiedAt: Date?

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
            lastBattledAt = date
            injuredAt = nil
            pendingCareMistakeAt = nil
            pendingLightsMistakeAt = nil
            lightsOffAt = nil
            collapsingAt = nil
            hungerEmptiedAt = nil
            strengthEmptiedAt = nil
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
            lastBattledAt: Date,
            injuredAt: Date?,
            pendingCareMistakeAt: Date?,
            pendingLightsMistakeAt: Date?,
            lightsOffAt: Date?,
            collapsingAt: Date?,
            hungerEmptiedAt: Date? = nil,
            strengthEmptiedAt: Date? = nil
        ) {
            self.bornAt = bornAt
            self.lastFedAt = lastFedAt
            self.lastTrainedAt = lastTrainedAt
            self.lastPoopAt = lastPoopAt
            self.lastHungerDecayAt = lastHungerDecayAt
            self.lastStrengthDecayAt = lastStrengthDecayAt
            self.evolvedAt = evolvedAt
            self.lastAdvancedAt = lastAdvancedAt
            self.lastBattledAt = lastBattledAt
            self.injuredAt = injuredAt
            self.pendingCareMistakeAt = pendingCareMistakeAt
            self.pendingLightsMistakeAt = pendingLightsMistakeAt
            self.lightsOffAt = lightsOffAt
            self.collapsingAt = collapsingAt
            self.hungerEmptiedAt = hungerEmptiedAt
            self.strengthEmptiedAt = strengthEmptiedAt
        }
    }
}

// MARK: - Factory

extension PetState {

    static func hatched(at date: Date = .now) -> PetState {
        let species = PetSpecies.dotkin
        return PetState(
            id: Tagged(rawValue: UUID()),
            species: species,
            hungerHearts: StatHearts(species.maxHunger),
            strengthHearts: StatHearts(species.maxStrength),
            weight: Weight(species.baseWeight),
            timestamps: Timestamps(creating: date)
        )
    }
}

// MARK: - Conditioning

nonisolated extension PetState {
    /// Whether the pet can build trained HP/POW. The Fresh runt (Dotkin) cannot.
    var canCondition: Bool { species != .dotkin }

    /// Hatched, alive, and awake — the gate for interactions and the waking
    /// simulators (hunger, strength, poop, injury).
    var isAwakeAndAlive: Bool { !isDead && !isEgg && !isSleeping }

    /// Both stats are empty — the pet is languishing and the collapse countdown
    /// toward death is running. Drives the on-screen weak look and Call sign.
    var isLanguishing: Bool {
        hungerHearts.isEmpty && strengthHearts.isEmpty
    }

    /// Lifetime steps needed to leave the current stage, including any lazy-day
    /// penalty. Guards the `Int.max` ultimate sentinel against overflow.
    var evolutionGoal: Int {
        let base = species.stage.stepsToEvolve
        guard base < Int.max - evolutionGoalPenalty else { return base }
        return base + evolutionGoalPenalty
    }

    /// Progress toward the next evolution as a 0...1 fraction, for the bezel ring.
    /// The final (ultimate) stage reads as a full ring.
    var evolutionProgressFraction: Double {
        guard species.stage != .ultimate else { return 1 }
        let goal = evolutionGoal
        guard goal > 0 else { return 0 }
        return min(1, max(0, Double(lifetimeActiveSteps) / Double(goal)))
    }
}
