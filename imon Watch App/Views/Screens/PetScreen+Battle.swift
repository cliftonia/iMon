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
                .aspectRatio(2, contentMode: .fit)

            case .approach, .clash, .result:
                LCDDisplay(
                    leftSprite: battle.petFrame,
                    rightSprite: battle.opponentFrame
                )
            }
        }
    }

    // MARK: - Battle Info Row

    @ViewBuilder
    var battleInfoRow: some View {
        if let battle = presenter.battlePresenter {
            Text(battlePhaseText(battle))
                .font(.system(
                    size: 12,
                    weight: .bold,
                    design: .monospaced
                ))
                .frame(height: 20)
        }
    }

    // MARK: - Battle Buttons

    @ViewBuilder
    var battleButtons: some View {
        if let battle = presenter.battlePresenter {
            if battle.viewModel.phase == .result {
                HStack(spacing: 4) {
                    ActionButton(label: "DONE") {
                        presenter.dismissBattle()
                    }
                }
                .padding(.horizontal, 4)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Private Helpers

    private func battlePhaseText(
        _ battle: BattlePresenter
    ) -> String {
        switch battle.viewModel.phase {
        case .intro: "VS"
        case .approach: "FIGHT!"
        case .clash: "CLASH!"
        case .result: battleResultText(battle)
        }
    }

    private func battleResultText(
        _ battle: BattlePresenter
    ) -> String {
        switch battle.viewModel.result {
        case .win: "YOU WIN!"
        case .lose: "YOU LOSE"
        case .draw: "DRAW"
        case .none: ""
        }
    }
}
