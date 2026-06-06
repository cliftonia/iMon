import SwiftUI
import WatchKit

struct PetScreen: View {

    let presenter: PetPresenter
    @Environment(AppPresenter.self) private var appPresenter
    @Environment(\.scenePhase) private var scenePhase
    @State private var crownValue: Double = 0

    private var screenMode: PetViewModel.ScreenMode {
        presenter.viewModel.screenMode
    }

    var body: some View {
        screenContent
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .focusable()
            .digitalCrownRotation(
                $crownValue,
                from: 0,
                through: 7,
                by: 1,
                sensitivity: .medium,
                isContinuous: false
            )
            .onChange(of: crownValue) { _, newValue in
                guard !presenter.viewModel.isBusy else { return }
                let allCases = PetViewModel.MenuAction.allCases
                let index = Int(newValue.rounded()) % allCases.count
                presenter.viewModel.menuSelection = allCases[index]
            }
            .onChange(of: presenter.viewModel.menuSelection) { _, newValue in
                crownValue = Double(newValue.rawValue)
            }
            .task {
                presenter.startGameLoop()
                appPresenter.weatherStore.refreshIfStale()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    appPresenter.weatherStore.refreshIfStale()
                }
            }
            .onChange(of: appPresenter.weatherStore.snapshot) { _, _ in
                presenter.environmentDidChange()
            }
            .onDisappear {
                presenter.stopGameLoop()
            }
            .sheet(
                isPresented: Bindable(presenter.viewModel)
                    .showEvolution
            ) {
                evolutionSheet
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Creature virtual pet")
    }

    // MARK: - Weather

    @ViewBuilder
    private var weatherHeader: some View {
        HStack(spacing: 0) {
            if let snapshot = appPresenter.weatherStore.displaySnapshot {
                WeatherOverlay(snapshot: snapshot)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        // Reserve the top-right for the system clock (which can't be hidden).
        .padding(.trailing, 58)
        .frame(height: 18)
        .contentShape(Rectangle())
        #if DEBUG
        .onTapGesture {
            appPresenter.weatherStore.cycleDebugCondition()
        }
        #endif
    }

    // MARK: - Debug Overlay

    @ViewBuilder
    private var debugNameOverlay: some View {
        #if DEBUG
        if let species = presenter.viewModel.status?.species {
            Text(species.displayName)
                .font(.system(
                    size: 9,
                    weight: .bold,
                    design: .monospaced
                ))
                .foregroundStyle(.yellow)
                .accessibilityHidden(true)
        }
        #endif
    }

    // MARK: - Screen Content

    @ViewBuilder
    private var screenContent: some View {
        switch screenMode {
        case .normal:
            normalLayout
        case .training:
            GameModeLayout {
                trainingLCD
            } info: {
                trainingInfoRow
            } buttons: {
                trainingButtons
            }
        case .battle:
            GameModeLayout {
                battleLCD
            } info: {
                battleInfoRow
            } buttons: {
                battleButtons
            }
        }
    }

    // MARK: - Normal Layout

    private var normalLayout: some View {
        VStack(spacing: 4) {
            weatherHeader

            LCDBezel {
                LCDDisplay(
                    leftSprite: presenter
                        .spriteAnimator.currentFrame,
                    rightSprite: effectRightSprite,
                    poopCount: presenter.viewModel.isBusy
                        ? 0
                        : presenter.viewModel.status?.poopCount
                            ?? 0,
                    stinkPhase: presenter
                        .spriteAnimator.currentFrameIndex,
                    lightsOn: presenter.viewModel.status?
                        .lightsOn ?? true,
                    leftSpriteOffsetX: presenter.viewModel
                        .petOffsetX,
                    weatherCondition: appPresenter
                        .weatherStore.displaySnapshot?.condition,
                    moonPhase: MoonPhase.current(date: .now)
                )
            }
            .fixedSize(horizontal: false, vertical: true)

            MenuIconRow(
                selectedIndex: presenter.viewModel
                    .menuSelection.rawValue
            )
            .lineLimit(1)
            .minimumScaleFactor(0.7)

            VStack(spacing: 2) {
                normalButtons
                debugNameOverlay
            }
            .frame(
                maxHeight: .infinity,
                alignment: .bottom
            )
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
        if presenter.feedingAnimator.isPlaying {
            return presenter.feedingAnimator.currentFrame
        }
        if presenter.viewModel.status?.isInjured == true {
            return SharedSprites.skull
        }
        return nil
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
