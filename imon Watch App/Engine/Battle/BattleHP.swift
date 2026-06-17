import Foundation

nonisolated enum BattleHP {

    static func calculate(for state: PetState, steps: Int? = nil) -> Int {
        // Per-species base stamina; a well-exercised wearer adds +1 when active,
        // plus any HP trained through battle practice.
        let base = state.species.baseHP
        let activeBonus = (steps.map { ActivityModel.factor(steps: $0) >= 0.5 } ?? false) ? 1 : 0
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
