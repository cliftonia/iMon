import Foundation

nonisolated enum TrainAction {

    enum Guess: Sendable {
        case high
        case low
    }

    struct RoundResult: Sendable {
        let number: Int
        let guess: Guess
        let won: Bool
    }

    // MARK: - Query

    static func canTrain(_ state: PetState) -> Bool {
        !state.isDead && !state.isEgg && !state.isSleeping
    }

    // MARK: - Round Logic

    /// Generate a training number in range 1-9, excluding 5.
    static func generateNumber() -> Int {
        var number = Int.random(in: 1...9)
        while number == 5 {
            number = Int.random(in: 1...9)
        }
        return number
    }

    /// Evaluate a single round against the player's guess.
    static func evaluateRound(number: Int, guess: Guess) -> RoundResult {
        let won: Bool = {
            switch guess {
            case .high: number > 5
            case .low: number < 5
            }
        }()
        return RoundResult(number: number, guess: guess, won: won)
    }

    // MARK: - Apply

    /// Apply the training session result to state.
    /// A winning session (>= 3/5 rounds won) grants +1 strength and -2G weight.
    /// Training count increments regardless of outcome.
    static func applyResult(
        to state: PetState,
        won: Bool,
        at date: Date = .now
    ) -> PetState {
        guard canTrain(state) else { return state }

        var state = state

        if won {
            state.strengthHearts.increment()
            state.weight.subtract(TimeConstants.trainWeightLoss)
        }

        state.trainingCount += 1
        state.lastTrainedAt = date
        let roll = Int.random(in: 1...10)
        switch roll {
        case 1...6:
            state.poopCount = min(TimeConstants.maxPoopPiles, state.poopCount + 1)
            state.lastPoopAt = date
        case 7...9:
            break
        default:
            if !state.isInjured {
                state.isInjured = true
                state.injuredAt = date
                state.injuryCount += 1
            }
        }

        return state
    }
}
