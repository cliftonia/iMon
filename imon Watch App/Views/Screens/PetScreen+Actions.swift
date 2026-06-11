import SwiftUI

// MARK: - Buttons, Effects & Menu Actions

extension PetScreen {

    // MARK: - Scene

    /// The home screen's scene: a clean booth during an action ceremony, else
    /// the full environment. Resolved by `SceneResolver` (the rules' home).
    var homeScene: LCDScene {
        SceneResolver.home(
            dayPhase: presenter.viewModel.dayPhase,
            lightsOn: presenter.viewModel.status?.lightsOn ?? true,
            weather: appPresenter.weatherStore.displaySnapshot?.condition,
            isInActionScene: presenter.viewModel.isInActionScene
        )
    }

    /// The battle / training arena: outdoors, lit by day and dark at night.
    var arenaScene: LCDScene {
        SceneResolver.arena(dayPhase: presenter.viewModel.dayPhase)
    }

    // MARK: - Button Labels

    var buttonALabel: String {
        presenter.viewModel.feedingPhase == .selecting ? "MEAT" : "A"
    }

    var buttonBLabel: String {
        presenter.viewModel.feedingPhase == .selecting ? "BACK" : "B"
    }

    var buttonCLabel: String {
        presenter.viewModel.feedingPhase == .selecting ? "VITA" : "C"
    }

    // MARK: - Effect Display

    var effectRightSprite: SpriteFrame? {
        if presenter.feedingAnimator.isPlaying {
            return presenter.feedingAnimator.currentFrame
        }
        if presenter.viewModel.status?.isInjured == true {
            return SharedSprites.skull
        }
        return nil
    }

    // MARK: - Button Handlers

    func handleButtonA() {
        guard !presenter.viewModel.isBusy
            || presenter.viewModel.feedingPhase == .selecting
        else { return }
        if presenter.viewModel.feedingPhase == .selecting {
            presenter.selectAndFeed(.meat)
        } else {
            presenter.selectPreviousMenu()
        }
    }

    func handleButtonB() {
        if presenter.viewModel.isBusy {
            presenter.cancelFeeding()
        } else {
            executeMenuAction()
        }
    }

    func handleButtonC() {
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

    var evolutionSheet: some View {
        VStack(spacing: 12) {
            Text("Evolving!")
                .font(.system(size: 14, weight: .bold, design: .monospaced))

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

    func executeMenuAction() {
        switch presenter.viewModel.menuSelection {
        case .stats:
            appPresenter.navigateToStats()
        case .feed:
            presenter.startFeeding()
        case .train:
            presenter.startTrainingMode()
        case .battle:
            presenter.startBattleMode()
        case .clean:
            presenter.cleanAction()
        case .lights:
            presenter.lightsAction()
        case .heal:
            presenter.healAction()
        case .call:
            presenter.debugEvolve()
            appPresenter.checkDeath()
        }
    }
}
