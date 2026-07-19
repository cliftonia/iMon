import Foundation

/// Battle stamina: species base HP, +1 while the wearer's step count clears
/// the active threshold, plus any HP earned through training.
nonisolated enum BattleHP {

    /// `steps` is today's running count; `nil` (steps disabled or unavailable)
    /// forgoes the active +1 bonus.
    static func calculate(for state: PetState, steps: Int? = nil) -> Int {
        let base = state.species.baseHP
        let activeBonus = (steps.map { ActivityModel.factor(steps: $0) >= TimeConstants.activeHPFactorThreshold } ?? false) ? 1 : 0
        return base + activeBonus + state.trainedHP
    }

    static func heartsString(hp: Int, maxHP: Int) -> String {
        String(repeating: "\u{2665}", count: hp)
            + String(
                repeating: "\u{2661}",
                count: max(0, maxHP - hp)
            )
    }
}
