import Foundation

// MARK: - Timing & Gameplay Constants (Digital Monster V1, 1997)

nonisolated enum TimeConstants {

    // MARK: - Stat Depletion

    /// Hunger hearts deplete one every 70 minutes
    static let hungerDepletionInterval: TimeInterval = 4_200

    /// Strength hearts deplete one every 60 minutes
    static let strengthDepletionInterval: TimeInterval = 3_600

    // MARK: - Lifecycle Events

    /// A poop pile appears every 2 hours
    static let poopInterval: TimeInterval = 7_200

    /// Owner has 20 minutes to respond to a care call before it counts as a care mistake
    static let careMistakeWindow: TimeInterval = 1_200

    /// Hour of the day the Digimon wakes up (7 AM)
    static let sleepWakeHour: Int = 7

    // MARK: - Evolution Timers

    /// Baby stage evolves after 2 minutes
    static let babyEvolutionTime: TimeInterval = 120

    /// In-Training evolves to Rookie after 10 minutes
    static let rookieEvolutionTime: TimeInterval = 600

    /// Rookie evolves to Champion after 1 hour
    static let championEvolutionTime: TimeInterval = 3_600

    /// Champion evolves to Ultimate after 2 hours
    static let ultimateEvolutionTime: TimeInterval = 7_200

    // MARK: - Game Loop

    /// Main simulation tick fires every 30 seconds
    static let gameTickInterval: TimeInterval = 30

    // MARK: - Limits

    /// Maximum poop piles on screen before health penalty
    static let maxPoopPiles: Int = 4

    /// Maximum hunger/strength hearts
    static let maxHearts: Int = 4

    /// Maximum weight in grams
    static let maxWeight: Int = 99

    /// Minimum weight in grams
    static let minWeight: Int = 5

    // MARK: - Death Thresholds

    /// Total care mistakes before the Digimon dies
    static let maxCareMistakesBeforeDeath: Int = 20

    /// Total untreated injuries before the Digimon dies
    static let maxInjuriesBeforeDeath: Int = 20

    /// An untreated injury leads to death after 6 hours
    static let untreatedInjuryDeathTime: TimeInterval = 21_600

    // MARK: - Feeding

    /// Weight gained from one serving of meat (grams)
    static let meatWeightGain: Int = 1

    /// Weight gained from one vitamin (grams)
    static let vitaminWeightGain: Int = 2

    // MARK: - Training

    /// Weight lost per completed training session (grams)
    static let trainWeightLoss: Int = 2

    /// Number of rounds in a training session
    static let trainRounds: Int = 5

    /// Wins needed in training to count as a successful session
    static let trainWinsNeeded: Int = 3

    // MARK: - Battle

    /// RNG variance applied to battle power calculations
    static let battleRNGVariance: Double = 0.20
}
