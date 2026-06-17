import SwiftUI
import WatchKit

struct PetScreen: View {

    let presenter: PetPresenter
    // Not private — the `+Actions` extension reads it for menu navigation.
    @Environment(AppPresenter.self) var appPresenter
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
                appPresenter.stepActivityStore.refreshIfStale()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    appPresenter.weatherStore.refreshIfStale()
                    appPresenter.stepActivityStore.refreshIfStale()
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
            // Tap the name to trigger an evolution (debug/manual).
            Button {
                presenter.debugEvolve()
            } label: {
                Text(species.displayName)
                    .font(.system(
                        size: 9,
                        weight: .bold,
                        design: .monospaced
                    ))
                    .foregroundStyle(.yellow)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Evolve")
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
                LCDDisplay(configuration: LCDDisplayConfiguration(
                    leftSprite: presenter.spriteAnimator.currentFrame,
                    rightSprite: effectRightSprite,
                    poopCount: presenter.viewModel.isInActionScene
                        ? 0
                        : presenter.viewModel.status?.poopCount ?? 0,
                    stinkPhase: presenter.spriteAnimator.currentFrameIndex,
                    lightsOn: homeScene.lightsOn,
                    leftSpriteOffsetX: presenter.viewModel.petOffsetX,
                    weatherCondition: homeScene.weather,
                    moonPhase: MoonPhase.current(date: .now),
                    dayPhase: homeScene.dayPhase
                ))
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

}
