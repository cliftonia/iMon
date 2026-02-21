import SwiftUI
import WatchKit

struct PetScreen: View {

    let presenter: PetPresenter
    @Environment(AppPresenter.self) private var appPresenter

    private var screenMode: PetViewModel.ScreenMode {
        presenter.viewModel.screenMode
    }

    var body: some View {
        VStack(spacing: 4) {
            // LCD Display
            LCDBezel {
                lcdContent
            }
            .fixedSize(horizontal: false, vertical: true)

            // Middle row — menu icons or context info
            middleRow

            // Bottom row — buttons
            bottomRow
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 12)
        .task {
            presenter.startGameLoop()
        }
        .onDisappear {
            presenter.stopGameLoop()
        }
        .sheet(isPresented: evolutionBinding) {
            evolutionSheet
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Digimon virtual pet")
    }

    // MARK: - LCD Content

    @ViewBuilder
    private var lcdContent: some View {
        switch screenMode {
        case .normal:
            LCDDisplay(
                leftSprite: presenter
                    .spriteAnimator.currentFrame,
                rightSprite: effectRightSprite,
                poopCount: presenter.viewModel.isBusy
                    ? 0
                    : presenter.viewModel.status?.poopCount
                        ?? 0,
                stinkPhase: presenter
                    .spriteAnimator.currentFrameIndex
            )
        case .training:
            trainingLCD
        case .battle:
            battleLCD
        }
    }

    // MARK: - Middle Row

    @ViewBuilder
    private var middleRow: some View {
        switch screenMode {
        case .normal:
            MenuIconRow(
                selectedIndex: presenter.viewModel.menuSelection
            )
            .fixedSize()
        case .training:
            trainingInfoRow
        case .battle:
            battleInfoRow
        }
    }

    // MARK: - Bottom Row

    @ViewBuilder
    private var bottomRow: some View {
        switch screenMode {
        case .normal:
            normalButtons
        case .training:
            trainingButtons
        case .battle:
            battleButtons
        }
    }

    // MARK: - Normal Buttons

    private var normalButtons: some View {
        HStack(spacing: 4) {
            ActionButton(label: buttonALabel) {
                handleButtonA()
            }
            ActionButton(label: buttonBLabel) {
                handleButtonB()
            }
            ActionButton(label: buttonCLabel) {
                handleButtonC()
            }
        }
        .padding(.horizontal, 4)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Button Labels

    private var buttonALabel: String {
        presenter.viewModel.feedingPhase == .selecting
            ? "MEAT" : "A"
    }

    private var buttonBLabel: String {
        presenter.viewModel.feedingPhase == .selecting
            ? "BACK" : "B"
    }

    private var buttonCLabel: String {
        presenter.viewModel.feedingPhase == .selecting
            ? "VITA" : "C"
    }

    // MARK: - Effect Display

    private var effectRightSprite: SpriteFrame? {
        guard presenter.viewModel.isBusy else { return nil }
        return presenter.feedingAnimator.currentFrame
    }

    // MARK: - Button Handlers

    private func handleButtonA() {
        guard !presenter.viewModel.isBusy
            || presenter.viewModel.feedingPhase == .selecting
        else { return }
        if presenter.viewModel.feedingPhase == .selecting {
            presenter.selectAndFeed(.meat)
        } else {
            presenter.selectPreviousMenu()
        }
    }

    private func handleButtonB() {
        if presenter.viewModel.isBusy {
            presenter.cancelFeeding()
        } else {
            executeMenuAction()
        }
    }

    private func handleButtonC() {
        guard !presenter.viewModel.isBusy
            || presenter.viewModel.feedingPhase == .selecting
        else { return }
        if presenter.viewModel.feedingPhase == .selecting {
            presenter.selectAndFeed(.vitamin)
        } else {
            presenter.selectNextMenu()
        }
    }

    // MARK: - Evolution Sheet

    private var evolutionBinding: Binding<Bool> {
        Binding(
            get: { presenter.viewModel.showEvolution },
            set: { presenter.viewModel.showEvolution = $0 }
        )
    }

    private var evolutionSheet: some View {
        VStack(spacing: 12) {
            Text("Evolving!")
                .font(.system(
                    size: 14,
                    weight: .bold,
                    design: .monospaced
                ))

            if let target = presenter.viewModel.evolutionTarget {
                Text(target.displayName)
                    .font(.system(size: 12, design: .monospaced))
            }

            Button("OK") {
                presenter.applyEvolution()
            }
            .accessibilityLabel("Confirm evolution")
        }
    }

    // MARK: - Menu Action

    private func executeMenuAction() {
        switch presenter.viewModel.menuSelection {
        case 0:
            appPresenter.navigateToStats()
        case 1:
            presenter.startFeeding()
        case 2:
            presenter.startTrainingMode()
        case 3:
            presenter.startBattleMode()
        case 4:
            presenter.cleanAction()
        case 5:
            presenter.lightsAction()
        case 6:
            presenter.healAction()
        default:
            break
        }
    }
}
