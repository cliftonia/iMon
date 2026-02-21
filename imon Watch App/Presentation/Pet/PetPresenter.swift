import Foundation
import os
import WatchKit

final class PetPresenter {

    private(set) var viewModel = PetViewModel()
    let spriteAnimator = SpriteAnimator()
    let feedingAnimator = SpriteAnimator()

    private(set) var trainingPresenter: TrainingPresenter?
    private(set) var battlePresenter: BattlePresenter?

    private var state: PetState
    private let store: PetStateStore
    private var gameTimer: Timer?
    private var feedingTask: Task<Void, Never>?
    private var cleaningTask: Task<Void, Never>?

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
    }

    func stopGameLoop() {
        gameTimer?.invalidate()
        gameTimer = nil
        cancelFeeding()
        cancelCleaning()
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

        // Don't let the pet fall asleep mid-ceremony
        if viewModel.isBusy, !wasSleeping, state.isSleeping {
            state.isSleeping = false
            state.lightsOn = true
        }

        updateViewModel()
        updateAnimation()
    }

    // MARK: - Feeding (Inline LCD Ceremony)

    func startFeeding() {
        guard FeedAction.canFeed(state) else {
            WKInterfaceDevice.rejectHaptic()
            return
        }
        viewModel.feedingPhase = .selecting
    }

    func selectAndFeed(_ food: FeedAction.FoodKind) {
        guard viewModel.feedingPhase == .selecting else { return }
        guard FeedAction.canFeed(state) else {
            WKInterfaceDevice.rejectHaptic()
            cancelFeeding()
            return
        }
        viewModel.selectedFood = food
        WKInterfaceDevice.buttonHaptic()
        feedingTask?.cancel()
        feedingTask = Task { [weak self] in
            await self?.runFeedingSequence()
        }
    }

    func cancelFeeding() {
        feedingTask?.cancel()
        feedingTask = nil
        viewModel.feedingPhase = .inactive
        feedingAnimator.stop()
        updateAnimation()
    }

    // MARK: - Feeding Sequence

    private func runFeedingSequence() async {
        let food = viewModel.selectedFood

        // Phase 1: Serving — food presented with steam/sparkle flair
        viewModel.feedingPhase = .serving
        let servingAnim = food == .meat
            ? SharedSprites.meatServing
            : SharedSprites.vitaminServing
        feedingAnimator.play(servingAnim)

        try? await Task.sleep(for: .milliseconds(800))
        guard !Task.isCancelled else { return }

        // Phase 2: Three deliberate bites
        let foodStages: [SpriteFrame] = food == .meat
            ? [SharedSprites.meatBite1, SharedSprites.meatBite2,
               SharedSprites.meatBone]
            : [SharedSprites.vitaminBite1, SharedSprites.vitaminBite2,
               SharedSprites.vitaminEmpty]

        for (index, stage) in foodStages.enumerated() {
            viewModel.feedingPhase = .bite(index + 1)

            // Pet chomps
            spriteAnimator.play(
                SpriteCatalog.animation(
                    for: state.species,
                    kind: .eat
                )
            )

            // Brief anticipation before food shrinks
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            // Food transitions to next bite stage
            feedingAnimator.play(.still(stage))
            WKInterfaceDevice.chompHaptic()

            // Savor the moment between bites
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
        }

        // Phase 3: Satisfaction — heart floats, pet rejoices
        viewModel.feedingPhase = .satisfied
        feedingAnimator.play(.still(SharedSprites.satisfactionHeart))
        spriteAnimator.play(
            SpriteCatalog.animation(
                for: state.species,
                kind: .happy
            )
        )
        WKInterfaceDevice.feedHaptic()

        // Apply the actual state change
        state = FeedAction.apply(to: state, food: food, at: .now)
        updateViewModel()
        save()

        try? await Task.sleep(for: .milliseconds(1000))
        guard !Task.isCancelled else { return }

        // Return to normal
        viewModel.feedingPhase = .inactive
        feedingAnimator.stop()
        updateAnimation()
    }

    // MARK: - Feed (Direct — no animation)

    func feedAction(food: FeedAction.FoodKind) {
        guard FeedAction.canFeed(state) else { return }
        state = FeedAction.apply(to: state, food: food, at: .now)
        spriteAnimator.play(
            SpriteCatalog.animation(for: state.species, kind: .eat)
        )
        updateViewModel()
        save()
        WKInterfaceDevice.feedHaptic()
    }

    // MARK: - Clean

    func cleanAction() {
        guard CleanAction.canClean(state) else {
            WKInterfaceDevice.rejectHaptic()
            return
        }
        cleaningTask?.cancel()
        cleaningTask = Task { [weak self] in
            await self?.runCleaningSequence()
        }
    }

    private func cancelCleaning() {
        cleaningTask?.cancel()
        cleaningTask = nil
        viewModel.isCleaningAnimation = false
        feedingAnimator.stop()
        updateAnimation()
    }

    private func runCleaningSequence() async {
        viewModel.isCleaningAnimation = true

        // Phase 1: Water drops shower over poop area
        feedingAnimator.play(SharedSprites.waterDrops)
        WKInterfaceDevice.cleanHaptic()

        try? await Task.sleep(for: .milliseconds(1200))
        guard !Task.isCancelled else { return }

        // Apply the clean — poop disappears
        state = CleanAction.apply(to: state, at: .now)
        updateViewModel()
        save()

        // Phase 2: Sparkle effect where poop was
        feedingAnimator.play(SharedSprites.cleanSparkle)

        try? await Task.sleep(for: .milliseconds(800))
        guard !Task.isCancelled else { return }

        // Return to normal
        viewModel.isCleaningAnimation = false
        feedingAnimator.stop()
        updateAnimation()
    }

    // MARK: - Heal

    func healAction() {
        guard HealAction.canHeal(state) else {
            WKInterfaceDevice.rejectHaptic()
            return
        }
        state = HealAction.apply(to: state, at: .now)
        updateViewModel()
        save()
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
            to: state,
            won: won,
            at: .now
        )
        if won {
            spriteAnimator.play(
                SpriteCatalog.animation(
                    for: state.species,
                    kind: .happy
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
            for: state,
            at: .now
        ) else {
            return
        }
        viewModel.showEvolution = true
        viewModel.evolutionTarget = target
    }

    func applyEvolution() {
        guard let target = viewModel.evolutionTarget else { return }
        state = EvolutionEngine.evolve(state, to: target, at: .now)
        viewModel.showEvolution = false
        viewModel.evolutionTarget = nil
        updateViewModel()
        updateAnimation()
        save()
        WKInterfaceDevice.evolveHaptic()
    }

    // MARK: - Menu Navigation

    func selectNextMenu() {
        viewModel.menuSelection = (viewModel.menuSelection + 1) % 8
    }

    func selectPreviousMenu() {
        viewModel.menuSelection =
            (viewModel.menuSelection - 1 + 8) % 8
    }

    // MARK: - Private Helpers

    private func updateViewModel() {
        viewModel.status = PetStatus(from: state)
    }

    func updateAnimation() {
        guard viewModel.screenMode == .normal else { return }
        guard !viewModel.isCleaningAnimation else { return }
        switch viewModel.feedingPhase {
        case .inactive, .selecting:
            let kind: SpriteCatalog.AnimationKind =
                state.isSleeping ? .sleep : .idle
            spriteAnimator.play(
                SpriteCatalog.animation(
                    for: state.species,
                    kind: kind
                )
            )
        case .serving, .bite, .satisfied:
            break
        }
    }

    private func save() {
        do {
            try store.save(state)
        } catch {
            Log.presentation.error(
                "Failed to save: \(error.localizedDescription)"
            )
        }
    }

    // MARK: - Training Mode (Inline)

    func startTrainingMode() {
        guard TrainAction.canTrain(state) else {
            WKInterfaceDevice.rejectHaptic()
            return
        }
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
    }

    // MARK: - Battle Mode (Inline)

    func startBattleMode() {
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
    }
}
