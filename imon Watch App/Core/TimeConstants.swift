import Foundation

// MARK: - Timing & Gameplay Constants

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

    /// A light left on at night accrues a mistake only every 3 hours, so one
    /// forgetful night nudges evolution toward neglect without hard-locking it.
    static let lightsMistakeWindow: TimeInterval = 10_800

    // MARK: - Game Loop

    /// Main simulation tick fires every 30 seconds
    static let gameTickInterval: TimeInterval = 30

    /// How long after the light goes off at bedtime before the pet drops off.
    static let sleepDelay: TimeInterval = 120

    /// The pet's bedtime: it only settles to sleep from 9pm until the morning
    /// wake hour, so an early winter dusk doesn't send it to bed at 5pm.
    static let sleepHour: Int = 21

    /// Fallback dark window (24h clock) used only when weather is unavailable.
    static let nightStartHour: Int = 18
    static let nightEndHour: Int = 6

    // MARK: - Limits

    /// Maximum poop piles on screen before health penalty
    static let maxPoopPiles: Int = 4

    // MARK: - Death Thresholds

    /// Total untreated injuries before the Creature dies
    static let maxInjuriesBeforeDeath: Int = 20

    /// An untreated injury leads to death after 6 hours (an acute condition the
    /// owner is expected to treat promptly).
    static let untreatedInjuryDeathTime: TimeInterval = 21_600

    /// A pet with no hunger and no strength collapses; left languishing this
    /// long (48 hours) without recovery, it finally perishes. Care mistakes no
    /// longer kill — they only steer evolution — so this is the sole neglect death.
    static let collapseDeathTime: TimeInterval = 172_800

    // MARK: - Notifications

    /// Local hour (24h) from which a low step count earns an exercise nudge.
    static let exerciseHour: Int = 15

    /// Today's steps below this after `exerciseHour` earn an exercise nudge.
    static let exerciseStepTarget: Int = 5_000

    /// Small lead before the exercise nudge fires, so it's prompt but not instant.
    static let exerciseNudgeLead: TimeInterval = 600

    /// How long before a collapse death to warn that the pet is fading (6 hours).
    static let nearingDeathLead: TimeInterval = 21_600

    // MARK: - Background Refresh

    /// How far ahead to request the next background wake (the system grants
    /// roughly one per hour for a Dock app, so asking sooner is pointless).
    static let backgroundRefreshInterval: TimeInterval = 3_600

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

    // MARK: - Conditioning (trained HP / POW)

    /// Maximum trained bonus for HP and POW.
    static let maxConditioning: Int = 3

    /// Neglect this long (no training / no battling) drops one trained point.
    static let conditioningDecayInterval: TimeInterval = 43_200

    /// Battle-power added per point of trained POW.
    static let trainedPowerWeight: Double = 8.0

    /// Battle-power added per strength heart.
    static let strengthPowerWeight: Double = 5.0

    /// Overweight pets fight at half power.
    static let overweightPowerPenalty: Double = 0.5

    /// Activity factor at or above this grants the active HP bonus.
    static let activeHPFactorThreshold: Double = 0.5

    // MARK: - Weather

    /// Cache window before re-fetching current weather (30 minutes)
    static let weatherCacheInterval: TimeInterval = 1_800

    /// Cache window before re-fetching today's step count (10 minutes)
    static let stepCacheInterval: TimeInterval = 600
}
