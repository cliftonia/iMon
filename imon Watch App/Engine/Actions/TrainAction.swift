import Foundation

nonisolated enum TrainAction {

    nonisolated enum Guess: Sendable {
        case high
        case low
    }

    nonisolated struct RoundResult: Sendable {
        let won: Bool
    }

    // MARK: - Query

    static func canTrain(_ state: PetState) -> Bool {
        state.isAwakeAndAlive
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
        return RoundResult(won: won)
    }

    // MARK: - Apply

    /// Apply the training session result to state.
    /// A winning session (>= 3/5 rounds won) grants +1 strength, -2G weight, and
    /// +1 trained HP (except for Dotkin). Training count increments regardless.
    static func applyResult(
        to state: PetState,
        won: Bool,
        at now: Date = .now
    ) -> PetState {
        guard canTrain(state) else { return state }

        var state = state

        if won {
            state.strengthHearts.increment(upTo: state.species.maxStrength)
            state.weight.subtract(TimeConstants.trainWeightLoss)
            if state.canCondition {
                state.trainedHP = min(
                    TimeConstants.maxConditioning, state.trainedHP + 1
                )
            }
        }

        state.trainingCount += 1
        state.timestamps.lastTrainedAt = now
        let roll = Int.random(in: 1...10)
        if (1...6).contains(roll) {
            state.poopCount = min(TimeConstants.maxPoopPiles, state.poopCount + 1)
            state.timestamps.lastPoopAt = now
        } else if roll == 10 {
            state.injure(at: now)
        }

        return state
    }
}
