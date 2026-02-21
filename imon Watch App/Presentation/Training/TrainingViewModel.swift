import Foundation
import Observation

@Observable
final class TrainingViewModel {

    var phase: TrainingPhase = .ready
    var currentRound: Int = 0
    var currentNumber: Int = 5
    var roundResults: [Bool] = []
    var isComplete: Bool = false
    var didWinSession: Bool = false
    var showingNumber: Bool = false

    enum TrainingPhase: Sendable {
        case ready
        case challenge
        case attacking
        case hit
        case miss
        case victory
        case defeat
    }
}
