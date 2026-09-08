import Foundation
import Observation

/// Display state for the Training screen: the state of one training run.
///
/// A run moves through `TrainingPhase`, tracking the current round, the
/// number being shown, and each round's result in `roundResults`.
@Observable
final class TrainingViewModel {

    var phase: TrainingPhase = .ready
    var currentRound: Int = 0
    var currentNumber: Int = 5
    var roundResults: [Bool] = []
    var showingNumber: Bool = false
    var lastGuessHigh: Bool = true

    /// The stage of a training run, from `ready` through the attack
    /// sequence to `victory` or `defeat`.
    enum TrainingPhase: Sendable {
        case ready
        case challenge
        case attacking
        case projectile
        case hit
        case miss
        case victory
        case defeat
    }
}
