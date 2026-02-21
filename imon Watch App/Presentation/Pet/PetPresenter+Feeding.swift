import Foundation
import WatchKit

extension PetPresenter {

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

    func runFeedingSequence() async {
        let food = viewModel.selectedFood
        await runServingPhase(food: food)
        guard !Task.isCancelled else { return }
        await runBitePhase(food: food)
        guard !Task.isCancelled else { return }
        await runSatisfactionPhase(food: food)
    }

    private func runServingPhase(
        food: FeedAction.FoodKind
    ) async {
        viewModel.feedingPhase = .serving
        let servingAnim = food == .meat
            ? SharedSprites.meatServing
            : SharedSprites.vitaminServing
        feedingAnimator.play(servingAnim)
        try? await Task.sleep(for: .milliseconds(800))
    }

    private func runBitePhase(
        food: FeedAction.FoodKind
    ) async {
        let foodStages: [SpriteFrame] = food == .meat
            ? [SharedSprites.meatBite1, SharedSprites.meatBite2,
               SharedSprites.meatBone]
            : [SharedSprites.vitaminBite1, SharedSprites.vitaminBite2,
               SharedSprites.vitaminEmpty]

        for (index, stage) in foodStages.enumerated() {
            viewModel.feedingPhase = .bite(index + 1)
            spriteAnimator.play(
                SpriteCatalog.animation(
                    for: state.species, kind: .eat
                )
            )
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            feedingAnimator.play(.still(stage))
            WKInterfaceDevice.chompHaptic()
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
        }
    }

    private func runSatisfactionPhase(
        food: FeedAction.FoodKind
    ) async {
        viewModel.feedingPhase = .satisfied
        feedingAnimator.play(.still(SharedSprites.satisfactionHeart))
        spriteAnimator.play(
            SpriteCatalog.animation(
                for: state.species, kind: .happy
            )
        )
        WKInterfaceDevice.feedHaptic()

        state = FeedAction.apply(to: state, food: food, at: .now)
        updateViewModel()
        save()

        try? await Task.sleep(for: .milliseconds(1000))
        guard !Task.isCancelled else { return }

        viewModel.feedingPhase = .inactive
        feedingAnimator.stop()
        updateAnimation()
    }

    // MARK: - Feed (Direct — no animation)

    func feedAction(food: FeedAction.FoodKind) {
        guard FeedAction.canFeed(state) else { return }
        state = FeedAction.apply(to: state, food: food, at: .now)
        spriteAnimator.play(
            SpriteCatalog.animation(
                for: state.species, kind: .eat
            )
        )
        updateViewModel()
        save()
        WKInterfaceDevice.feedHaptic()
    }

    // MARK: - Clean

    func cleanAction() {
        guard !viewModel.isBusy else { return }
        guard CleanAction.canClean(state) else {
            refuseTask?.cancel()
            refuseTask = Task { [weak self] in
                await self?.runRefuseSequence()
            }
            return
        }
        cleaningTask?.cancel()
        cleaningTask = Task { [weak self] in
            await self?.runCleaningSequence()
        }
    }

    func cancelCleaning() {
        cleaningTask?.cancel()
        cleaningTask = nil
        viewModel.isCleaningAnimation = false
        feedingAnimator.stop()
        updateAnimation()
    }

    func runCleaningSequence() async {
        viewModel.isCleaningAnimation = true

        feedingAnimator.play(SharedSprites.waterDrops)
        WKInterfaceDevice.cleanHaptic()

        try? await Task.sleep(for: .milliseconds(1200))
        guard !Task.isCancelled else { return }

        state = CleanAction.apply(to: state, at: .now)
        updateViewModel()
        save()

        feedingAnimator.play(SharedSprites.cleanSparkle)

        try? await Task.sleep(for: .milliseconds(800))
        guard !Task.isCancelled else { return }

        viewModel.isCleaningAnimation = false
        feedingAnimator.stop()
        updateAnimation()
    }
}
