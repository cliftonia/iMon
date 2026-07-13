import Foundation
import WatchKit

extension PetPresenter {

    // MARK: - Feeding (Inline LCD Ceremony)

    func startFeeding() {
        guard FeedAction.canFeed(state) else {
            refuse()
            return
        }
        viewModel.activity = .feeding(.selecting)
    }

    func selectAndFeed(_ food: FeedAction.FoodKind) {
        guard viewModel.feedingPhase == .selecting else { return }
        guard FeedAction.canFeed(state) else {
            WKInterfaceDevice.rejectHaptic()
            cancelActivity()
            return
        }
        guard !FeedAction.isSated(state, food: food) else {
            // Already full on this stat — shake it off rather than overfeed.
            refuse()
            return
        }
        viewModel.selectedFood = food
        WKInterfaceDevice.buttonHaptic()
        startActivity { await $0.runFeedingSequence() }
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
        viewModel.activity = .feeding(.serving)
        let servingAnim = food == .meat
            ? SharedSprites.meatServing
            : SharedSprites.vitaminServing
        feedingAnimator.play(servingAnim)

        let idle = SpriteCatalog.animation(for: state.species, kind: .idle)
        spriteAnimator.play(idle.facing(.left))

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

        let chomp = SpriteCatalog.animation(
            for: state.species, kind: .eat
        ).facing(.left)

        for (index, stage) in foodStages.enumerated() {
            viewModel.activity = .feeding(.bite(index + 1))
            spriteAnimator.play(chomp)
            guard await pause(ms: 300) else { return }

            feedingAnimator.play(.still(stage))
            WKInterfaceDevice.chompHaptic()
            guard await pause(ms: 400) else { return }
        }
    }

    private func runSatisfactionPhase(
        food: FeedAction.FoodKind
    ) async {
        viewModel.activity = .feeding(.satisfied)
        feedingAnimator.play(.still(SharedSprites.satisfactionHeart))
        let happy = SpriteCatalog.animation(
            for: state.species, kind: .happy
        ).facing(.left)
        spriteAnimator.play(happy)
        WKInterfaceDevice.feedHaptic()

        state = FeedAction.apply(to: state, food: food, at: .now)
        updateViewModel()
        save()

        guard await pause(ms: 1000) else { return }

        endActivity()
    }

    // MARK: - Clean

    func cleanAction() {
        guard !viewModel.isBusy else { return }
        guard CleanAction.canClean(state) else {
            refuse()
            return
        }
        startActivity { await $0.runCleaningSequence() }
    }

    func runCleaningSequence() async {
        viewModel.activity = .cleaning

        feedingAnimator.play(SharedSprites.waterDrops)
        WKInterfaceDevice.cleanHaptic()

        guard await pause(ms: 1200) else { return }

        state = CleanAction.apply(to: state, at: .now)
        updateViewModel()
        save()

        feedingAnimator.play(SharedSprites.cleanSparkle)

        guard await pause(ms: 800) else { return }

        endActivity()
    }
}
