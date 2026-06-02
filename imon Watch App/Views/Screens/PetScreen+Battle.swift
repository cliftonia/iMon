import SwiftUI

extension PetScreen {

    // MARK: - Battle LCD

    @ViewBuilder
    var battleLCD: some View {
        if let battle = presenter.battlePresenter {
            switch battle.viewModel.phase {
            case .intro:
                LCDDisplay(
                    leftSprite: .empty,
                    lightsOn: battle.viewModel.lightsOn
                )
                .overlay {
                    HStack(spacing: 0) {
                        Text(
                            battle.viewModel.petSpecies
                                .displayName
                        )
                        .font(.system(
                            size: 9,
                            design: .monospaced
                        ))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)

                        Text("VS")
                            .font(.system(
                                size: 10,
                                weight: .bold,
                                design: .monospaced
                            ))
                            .fixedSize()

                        Text(
                            battle.viewModel.opponentSpecies
                                .displayName
                        )
                        .font(.system(
                            size: 9,
                            design: .monospaced
                        ))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 4)
                }
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
                    leftSpriteOffsetX: battle.activeOffsetX,
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
            let phaseText = battlePhaseText(battle)
            if phaseText.isEmpty {
                choosingInfoRow(battle)
            } else {
                Text(phaseText)
                    .font(.system(
                        size: 11,
                        weight: .bold,
                        design: .monospaced
                    ))
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
            }
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

            case .victory, .defeat:
                HStack(spacing: 4) {
                    ActionButton(label: "DONE") {
                        presenter.dismissBattle()
                    }
                }

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

    private func choosingInfoRow(
        _ battle: BattlePresenter
    ) -> some View {
        let petHearts = BattleHP.heartsString(
            hp: battle.viewModel.petHP,
            maxHP: battle.viewModel.petMaxHP
        )
        let oppHearts = BattleHP.heartsString(
            hp: battle.viewModel.opponentHP,
            maxHP: battle.viewModel.opponentMaxHP
        )
        let petName = battle.viewModel.petSpecies.displayName
        let oppName = battle.viewModel.opponentSpecies
            .displayName
        return HStack(spacing: 2) {
            Text("\(petName) \(petHearts)")
            Text("|")
            Text("\(oppName) \(oppHearts)")
        }
        .font(.system(
            size: 9,
            weight: .medium,
            design: .monospaced
        ))
        .minimumScaleFactor(0.7)
        .lineLimit(1)
        .accessibilityLabel(
            "\(petName) \(battle.viewModel.petHP) HP,"
                + " \(oppName) \(battle.viewModel.opponentHP) HP"
        )
    }


    private func battlePhaseText(
        _ battle: BattlePresenter
    ) -> String {
        switch battle.viewModel.phase {
        case .intro: ""
        case .approach: "FIGHT!"
        case .choosing: ""
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
