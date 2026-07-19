import Foundation

/// The training mini-game: guess whether a hidden number (1–9, never 5, so a
/// guess always has a true answer) lands high or low. A winning session builds
/// strength, sheds weight and adds trained HP; win or lose, the exertion risks
/// a poop (60%) or an injury (10%).
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

    static func generateNumber() -> Int {
        var number = Int.random(in: 1...9)
        while number == 5 {
            number = Int.random(in: 1...9)
        }
        return number
    }

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
