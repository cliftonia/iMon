import Foundation
import os
import WatchKit

final class PetPresenter {

    private(set) var viewModel = PetViewModel()
    let spriteAnimator = SpriteAnimator()
    let feedingAnimator = SpriteAnimator()

    var trainingPresenter: TrainingPresenter?
    var battlePresenter: BattlePresenter?

    var state: PetState
    let store: PetStateStore
    private var gameTimer: Timer?
    var wanderTimer: Timer?
    var feedingTask: Task<Void, Never>?
    var cleaningTask: Task<Void, Never>?
    var healingTask: Task<Void, Never>?
    var refuseTask: Task<Void, Never>?
    var sleepToggleTask: Task<Void, Never>?

    // MARK: - Wander State

    enum WanderState {
        case idle
        case walking(direction: Int, stepsRemaining: Int)
    }

    var wanderState: WanderState = .idle

    // MARK: - Init

    init(state: PetState, store: PetStateStore) {
        self.state = state
        self.store = store
        updateViewModel()
    }

    // MARK: - Game Loop

    func startGameLoop() {
        advanceState()
        gameTimer = Timer.scheduledTimer(
            withTimeInterval: TimeConstants.gameTickInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        startWandering()
    }

    func stopGameLoop() {
        gameTimer?.invalidate()
        gameTimer = nil
        stopWandering()
        cancelFeeding()
        cancelCleaning()
        cancelHealing()
        refuseTask?.cancel()
        refuseTask = nil
        sleepToggleTask?.cancel()
        sleepToggleTask = nil
        dismissTraining()
        dismissBattle()
    }

    private func tick() {
        advanceState()
        checkEvolution()
        save()
    }

    private func advanceState() {
        let wasSleeping = state.isSleeping
        state = GameEngine.advance(state, to: .now)

        if !wasSleeping, state.isSleeping, viewModel.isBusy {
            state.isSleeping = false
            state.lightsOn = true
        }

        updateViewModel()
        updateAnimation()
    }

    // MARK: - Debug Evolution

    /// Debug: walk through each evolution journey, resetting
    /// to egg between them. Loops back to journey 1 at the end.
    private static let debugJourneys: [[DigimonSpecies]] = [
        [.botamon, .koromon, .agumon, .greymon, .metalGreymon],
        [.botamon, .koromon, .betamon, .tyrannomon, .mamemon],
        [.botamon, .koromon, .agumon, .devimon, .metalGreymon],
        [.botamon, .koromon, .agumon, .meramon, .mamemon],
        [.botamon, .koromon, .betamon, .airdramon, .metalGreymon],
        [.botamon, .koromon, .betamon, .seadramon, .mamemon],
        [.botamon, .koromon, .agumon, .numemon, .monzaemon]
    ]

    private static let debugJourneyKey = "debugJourneyIndex"

    private var debugJourneyIndex: Int {
        get { UserDefaults.standard.integer(forKey: Self.debugJourneyKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.debugJourneyKey) }
    }

    private var debugStepIndex = 0

    func debugEvolve() {
        guard !viewModel.isBusy else { return }

        let journeys = Self.debugJourneys
        let journey = journeys[debugJourneyIndex]

        let nextStep = debugStepIndex + 1
        if nextStep >= journey.count {
            state.isDead = true
            let next = debugJourneyIndex + 1
            debugJourneyIndex = next >= journeys.count
                ? 0 : next
            debugStepIndex = 0
            updateViewModel()
            save()
        } else {
            let target = journey[nextStep]
            debugStepIndex = nextStep
            viewModel.showEvolution = true
            viewModel.evolutionTarget = target
        }
    }

    // MARK: - Lights

    func lightsAction() {
        guard LightsAction.canToggle(state) else {
            WKInterfaceDevice.rejectHaptic()
            return
        }
        sleepToggleTask?.cancel()
        sleepToggleTask = nil

        let (newState, result) = LightsAction.apply(
            to: state, at: .now
        )
        state = newState
        updateViewModel()
        updateAnimation()
        save()

        if result == .toggledDuringSleep {
            scheduleSleepToggleResolution()
        }
    }

    private func scheduleSleepToggleResolution() {
        sleepToggleTask = Task { [weak self] in
            try? await Task.sleep(
                for: .seconds(TimeConstants.lightsToggleSleepDelay)
            )
            guard !Task.isCancelled else { return }
            self?.resolveSleepToggle()
        }
    }

    private func resolveSleepToggle() {
        guard state.lightsToggledDuringSleepAt != nil else {
            return
        }
        if state.lightsOn {
            state.isSleeping = false
        } else {
            state.isSleeping = true
            state.lightsToggledDuringSleepAt = nil
        }
        updateViewModel()
        updateAnimation()
        save()
    }

    // MARK: - Training Result

    func applyTrainingResult(won: Bool) {
        state = TrainAction.applyResult(
            to: state, won: won, at: .now
        )
        if won {
            spriteAnimator.play(
                SpriteCatalog.animation(
                    for: state.species, kind: .happy
                )
            )
        }
        updateViewModel()
        save()
    }

    // MARK: - Battle Result

    func applyBattleResult(_ result: BattleResult) {
        state = BattleEngine.applyResult(result, to: state)
        updateViewModel()
        save()
    }

    // MARK: - State Access

    func getCurrentState() -> PetState { state }

    // MARK: - Evolution

    private func checkEvolution() {
        guard let target = EvolutionEngine.checkEvolution(
            for: state, at: .now
        ) else {
            return
        }
        viewModel.showEvolution = true
        viewModel.evolutionTarget = target
    }

    func applyEvolution() {
        guard let target = viewModel.evolutionTarget else {
            return
        }
        state = EvolutionEngine.evolve(
            state, to: target, at: .now
        )
        if debugStepIndex > 0 {
            state.poopCount = 1
            state.isInjured = true
        }
        viewModel.showEvolution = false
        viewModel.evolutionTarget = nil
        updateViewModel()
        updateAnimation()
        save()
        WKInterfaceDevice.evolveHaptic()
    }

    // MARK: - Menu Navigation

    func selectNextMenu() {
        let all = PetViewModel.MenuAction.allCases
        let index = (viewModel.menuSelection.rawValue + 1)
            % all.count
        viewModel.menuSelection = all[index]
    }

    func selectPreviousMenu() {
        let all = PetViewModel.MenuAction.allCases
        let index = (viewModel.menuSelection.rawValue - 1
            + all.count) % all.count
        viewModel.menuSelection = all[index]
    }

    // MARK: - Helpers

    func updateViewModel() {
        viewModel.status = PetStatus(from: state)
    }

    func updateAnimation() {
        guard viewModel.screenMode == .normal else { return }
        guard !viewModel.isCleaningAnimation else { return }
        guard !viewModel.isHealingAnimation else { return }
        switch viewModel.feedingPhase {
        case .inactive, .selecting:
            let kind: SpriteCatalog.AnimationKind =
                state.isSleeping ? .sleep : .idle
            spriteAnimator.play(
                SpriteCatalog.animation(
                    for: state.species, kind: kind
                )
            )
        case .serving, .bite, .satisfied:
            break
        }
    }

    func save() {
        do {
            try store.save(state)
        } catch {
            Log.presentation.error(
                "Failed to save: \(error.localizedDescription)"
            )
        }
    }

}
