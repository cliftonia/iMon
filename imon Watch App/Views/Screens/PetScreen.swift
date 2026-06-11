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
                    lightsOn: presenter.viewModel.status?.lightsOn ?? true,
                    leftSpriteOffsetX: presenter.viewModel
                        .petOffsetX,
                    // Feeding, cleaning and healing happen in place (full
                    // environment); only battle and training go to the arena.
                    weatherCondition: appPresenter
                        .weatherStore.displaySnapshot?.condition,
                    moonPhase: MoonPhase.current(date: .now),
                    dayPhase: presenter.viewModel.dayPhase
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

}
