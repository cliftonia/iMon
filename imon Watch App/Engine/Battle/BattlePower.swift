import Foundation

/// Effective battle power: species base plus bonuses from current strength
/// hearts and trained POW, halved when overweight — an overfed pet fights
/// at a handicap.
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
