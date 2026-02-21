import Foundation
import os
import WatchKit

final class PetPresenter {

    private(set) var viewModel = PetViewModel()
    let spriteAnimator = SpriteAnimator()
    let feedingAnimator = SpriteAnimator()

    private(set) var trainingPresenter: TrainingPresenter?
    private(set) var battlePresenter: BattlePresenter?

    var state: PetState
    let store: PetStateStore
    private var gameTimer: Timer?
    private var wanderTimer: Timer?
    var feedingTask: Task<Void, Never>?
    var cleaningTask: Task<Void, Never>?
    var healingTask: Task<Void, Never>?
    var refuseTask: Task<Void, Never>?

    // MARK: - Wander State

    enum WanderState {
        case idle
        case walking(direction: Int, stepsRemaining: Int)
    }

    private var wanderState: WanderState = .idle

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

        if viewModel.isBusy, !wasSleeping, state.isSleeping {
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
        state = LightsAction.apply(to: state)
        updateViewModel()
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

    // MARK: - Wandering

    func startWandering() {
        scheduleNextWander()
    }

    func stopWandering() {
        wanderTimer?.invalidate()
        wanderTimer = nil
        wanderState = .idle
        viewModel.petOffsetX = 8
    }

    private var shouldPauseWander: Bool {
        viewModel.isBusy
            || viewModel.screenMode != .normal
            || state.isSleeping
            || state.isDead
    }

    private func scheduleNextWander() {
        wanderTimer?.invalidate()
        let delay = Double.random(in: 3...8)
        wanderTimer = Timer.scheduledTimer(
            withTimeInterval: delay,
            repeats: false
        ) { [weak self] _ in
            Task { @MainActor in
                self?.tryStartWalking()
            }
        }
    }

    private func tryStartWalking() {
        guard !shouldPauseWander else {
            scheduleNextWander()
            return
        }

        // 60% chance to walk, 40% stay idle
        guard Double.random(in: 0...1) < 0.6 else {
            scheduleNextWander()
            return
        }

        let offsetX = viewModel.petOffsetX
        let direction: Int
        if offsetX <= 3 {
            direction = 1
        } else if offsetX >= 13 {
            direction = -1
        } else {
            direction = Bool.random() ? 1 : -1
        }

        let steps = Int.random(in: 3...6)
        wanderState = .walking(
            direction: direction,
            stepsRemaining: steps
        )

        let animation = SpriteCatalog.animation(
            for: state.species, kind: .sideWalk
        )
        if direction < 0 {
            let mirrored = SpriteAnimation(
                frames: animation.frames.map { $0.mirrored() },
                frameDuration: animation.frameDuration,
                loops: animation.loops
            )
            spriteAnimator.play(mirrored)
        } else {
            spriteAnimator.play(animation)
        }

        wanderTimer = Timer.scheduledTimer(
            withTimeInterval: 0.35,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.wanderStep()
            }
        }
    }

    private func wanderStep() {
        guard case .walking(
            let direction,
            let remaining
        ) = wanderState else {
            returnToIdle()
            return
        }

        if shouldPauseWander {
            returnToIdle()
            return
        }

        let newX = viewModel.petOffsetX + direction
        guard newX >= 2, newX <= 14, remaining > 0 else {
            returnToIdle()
            return
        }

        viewModel.petOffsetX = newX
        wanderState = .walking(
            direction: direction,
            stepsRemaining: remaining - 1
        )

        if remaining - 1 <= 0 {
            returnToIdle()
        }
    }

    private func returnToIdle() {
        wanderTimer?.invalidate()
        wanderTimer = nil
        wanderState = .idle
        updateAnimation()
        scheduleNextWander()
    }

    // MARK: - Training Mode (Inline)

    func startTrainingMode() {
        guard TrainAction.canTrain(state) else {
            refuseTask?.cancel()
            refuseTask = Task { [weak self] in
                await self?.runRefuseSequence()
            }
            return
        }
        stopWandering()
        let presenter = TrainingPresenter(
            species: state.species
        ) { [weak self] won in
            self?.applyTrainingResult(won: won)
        }
        trainingPresenter = presenter
        viewModel.screenMode = .training
        presenter.startTraining()
    }

    func dismissTraining() {
        trainingPresenter?.spriteAnimator.stop()
        trainingPresenter?.targetAnimator.stop()
        trainingPresenter = nil
        viewModel.screenMode = .normal
        updateAnimation()
        startWandering()
    }

    // MARK: - Battle Mode (Inline)

    func startBattleMode() {
        stopWandering()
        let presenter = BattlePresenter(
            petState: state
        ) { [weak self] result in
            self?.applyBattleResult(result)
        }
        battlePresenter = presenter
        viewModel.screenMode = .battle
        presenter.startBattle()
    }

    func dismissBattle() {
        battlePresenter?.petAnimator.stop()
        battlePresenter?.opponentAnimator.stop()
        battlePresenter = nil
        viewModel.screenMode = .normal
        updateAnimation()
        startWandering()
    }
}
