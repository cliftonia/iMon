import SwiftUI

extension PetScreen {

    // MARK: - Battle LCD

    @ViewBuilder
    var battleLCD: some View {
        if let battle = presenter.battlePresenter {
            switch battle.viewModel.phase {
            case .intro:
                HStack(spacing: 0) {
                    Text(battle.viewModel.petSpecies.displayName)
                        .font(.system(
                            size: 9,
                            design: .monospaced
                        ))
                        .frame(maxWidth: .infinity)

                    Text("VS")
                        .font(.system(
                            size: 8,
                            weight: .bold,
                            design: .monospaced
                        ))

                    Text(
                        battle.viewModel.opponentSpecies
                            .displayName
                    )
                    .font(.system(
                        size: 9,
                        design: .monospaced
                    ))
                    .frame(maxWidth: .infinity)
                }
                .padding(8)
                .background(Color("LCDBackground"))
                .aspectRatio(32.0 / 20.0, contentMode: .fit)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(
                    "\(battle.viewModel.petSpecies.displayName)"
                        + " versus "
                        + "\(battle.viewModel.opponentSpecies.displayName)"
                )

            default:
                LCDDisplay(
                    leftSprite: battle.activeFrame,
                    lightsOn: battle.viewModel.lightsOn,
                    leftSpriteOffsetY: battleSpriteOffsetY(
                        battle
                    )
                )
            }
        }
    }

    // MARK: - Battle Info Row

    @ViewBuilder
    var battleInfoRow: some View {
        if let battle = presenter.battlePresenter {
            VStack(spacing: 2) {
                battleHPRow(battle)
                Text(battlePhaseText(battle))
                    .font(.system(
                        size: 12,
                        weight: .bold,
                        design: .monospaced
                    ))
            }
            .frame(height: 28)
        }
    }

    // MARK: - Battle Buttons

    @ViewBuilder
    var battleButtons: some View {
        if let battle = presenter.battlePresenter {
            switch battle.viewModel.phase {
            case .choosing:
                HStack(spacing: 4) {
                    ActionButton(label: "HIGH") {
                        battle.pickAction(.high)
                    }
                    ActionButton(label: "MED") {
                        battle.pickAction(.medium)
                    }
                    ActionButton(label: "LOW") {
                        battle.pickAction(.low)
                    }
                }
                .padding(.horizontal, 4)
                .fixedSize(horizontal: false, vertical: true)

            case .victory, .defeat:
                HStack(spacing: 4) {
                    ActionButton(label: "DONE") {
                        presenter.dismissBattle()
                    }
                }
                .padding(.horizontal, 4)
                .fixedSize(horizontal: false, vertical: true)

            default:
                EmptyView()
            }
        }
    }

    // MARK: - Private Helpers

    private func battleSpriteOffsetY(
        _ battle: BattlePresenter
    ) -> Int {
        let isCenteredImpact = battle.viewModel.phase == .impact
            && (battle.viewModel.lastRoundOutcome == .clash
                || battle.viewModel.lastRoundOutcome == .opponentHit)
        return isCenteredImpact ? 2 : 4
    }

    private func battleHPRow(
        _ battle: BattlePresenter
    ) -> some View {
        let petHearts = String(
            repeating: "\u{2665}",
            count: battle.viewModel.petHP
        ) + String(
            repeating: "\u{2661}",
            count: max(
                0,
                battle.viewModel.petMaxHP
                    - battle.viewModel.petHP
            )
        )
        let oppHearts = String(
            repeating: "\u{2665}",
            count: battle.viewModel.opponentHP
        ) + String(
            repeating: "\u{2661}",
            count: max(
                0,
                battle.viewModel.opponentMaxHP
                    - battle.viewModel.opponentHP
            )
        )
        return Text("YOU \(petHearts)  FOE \(oppHearts)")
            .font(.system(
                size: 9,
                weight: .medium,
                design: .monospaced
            ))
            .accessibilityLabel(
                "You \(battle.viewModel.petHP) HP,"
                    + " Foe \(battle.viewModel.opponentHP) HP"
            )
    }

    private func battlePhaseText(
        _ battle: BattlePresenter
    ) -> String {
        switch battle.viewModel.phase {
        case .intro: "VS"
        case .approach: "FIGHT!"
        case .choosing: "CHOOSE!"
        case .attacking, .projectile: "ATTACK!"
        case .opponentAttacking: "COUNTER!"
        case .opponentProjectile: "INCOMING!"
        case .impact: impactText(battle)
        case .victory: victoryText(battle)
        case .defeat: "YOU LOSE"
        }
    }

    private func impactText(
        _ battle: BattlePresenter
    ) -> String {
        switch battle.viewModel.lastRoundOutcome {
        case .playerHit: "HIT!"
        case .opponentHit: "MISS!"
        case .clash: "CLASH!"
        case .none: ""
        }
    }

    private func victoryText(
        _ battle: BattlePresenter
    ) -> String {
        switch battle.viewModel.result {
        case .win: "YOU WIN!"
        case .draw: "DRAW"
        case .lose, .none: ""
        }
    }
}
