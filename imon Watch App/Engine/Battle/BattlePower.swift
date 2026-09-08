import Foundation

/// Computes effective battle power from `PetState`: species base power plus
/// bonuses from current strength hearts and trained power, halved while the
/// pet is overweight.
nonisolated enum BattlePower {

    static func calculate(for state: PetState) -> Double {
        let base = Double(state.species.basePower)
        let strengthBonus = Double(state.strengthHearts.value) * TimeConstants.strengthPowerWeight
        let trainedBonus = Double(state.trainedPower) * TimeConstants.trainedPowerWeight
        let raw = base + strengthBonus + trainedBonus

        if state.weight.isOverweight {
            return raw * TimeConstants.overweightPowerPenalty
        }

        return raw
    }
}
