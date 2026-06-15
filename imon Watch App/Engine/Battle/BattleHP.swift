import Foundation

nonisolated enum BattleHP {

    static func calculate(for state: PetState, steps: Int? = nil) -> Int {
        let base = state.species.stage.battleHP
        let hungerBonus = state.hungerHearts.value >= 3 ? 1 : 0
        let strengthBonus = state.strengthHearts.value >= 3 ? 1 : 0
        // A well-exercised wearer makes a fitter fighter: +1 stamina when active.
        let activeBonus = (steps.map { ActivityModel.factor(steps: $0) >= 0.5 } ?? false) ? 1 : 0
        return base + hungerBonus + strengthBonus + activeBonus
    }

    static func heartsString(hp: Int, maxHP: Int) -> String {
        String(repeating: "\u{2665}", count: hp)
            + String(
                repeating: "\u{2661}",
                count: max(0, maxHP - hp)
            )
    }
}
