import Foundation

nonisolated enum BattleEngine {

    /// Run a battle between pet and opponent.
    /// Applies attribute advantages and RNG variance to determine outcome.
    static func battle(
        petState: PetState,
        opponent: BattleOpponent
    ) -> BattleResult {
        let petPower = BattlePower.calculate(for: petState)
        var effectivePetPower = petPower
        var effectiveOpponentPower = opponent.power

        // Attribute advantage: +20%
        if petState.species.attribute.hasAdvantageOver(opponent.attribute) {
            effectivePetPower *= 1.2
        } else if opponent.attribute.hasAdvantageOver(petState.species.attribute) {
            effectiveOpponentPower *= 1.2
        }

        // RNG variance
        let variance = TimeConstants.battleRNGVariance
        let petRNG = Double.random(in: (1 - variance)...(1 + variance))
        let opponentRNG = Double.random(in: (1 - variance)...(1 + variance))

        let finalPet = effectivePetPower * petRNG
        let finalOpponent = effectiveOpponentPower * opponentRNG

        let difference = abs(finalPet - finalOpponent)
        let threshold = max(finalPet, finalOpponent) * 0.05

        if difference < threshold { return .draw }
        return finalPet > finalOpponent ? .win : .lose
    }

    /// Apply battle result to state, incrementing win/loss counters.
    static func applyResult(
        _ result: BattleResult,
        to state: PetState
    ) -> PetState {
        var state = state
        switch result {
        case .win: state.battleWins += 1
        case .lose: state.battleLosses += 1
        case .draw: break
        }
        return state
    }
}
