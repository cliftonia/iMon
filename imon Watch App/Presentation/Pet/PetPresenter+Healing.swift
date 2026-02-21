import Foundation
import WatchKit

extension PetPresenter {

    // MARK: - Healing (Inline LCD Ceremony)

    func healAction() {
        guard HealAction.canHeal(state) else {
            WKInterfaceDevice.rejectHaptic()
            return
        }
        healingTask?.cancel()
        healingTask = Task { [weak self] in
            await self?.runHealingSequence()
        }
    }

    func cancelHealing() {
        healingTask?.cancel()
        healingTask = nil
        viewModel.isHealingAnimation = false
        feedingAnimator.stop()
        updateAnimation()
    }

    func runHealingSequence() async {
        viewModel.isHealingAnimation = true

        // Phase 1: Needle injection (1200ms)
        feedingAnimator.play(SharedSprites.needleInjection)
        WKInterfaceDevice.healHaptic()

        try? await Task.sleep(for: .milliseconds(1200))
        guard !Task.isCancelled else { return }

        // Phase 2: Apply heal
        state = HealAction.apply(to: state, at: .now)
        updateViewModel()
        save()

        // Phase 3: Satisfaction heart + happy bounce (1000ms)
        feedingAnimator.play(
            .still(SharedSprites.satisfactionHeart)
        )
        spriteAnimator.play(
            SpriteCatalog.animation(
                for: state.species, kind: .happy
            )
        )

        try? await Task.sleep(for: .milliseconds(1000))
        guard !Task.isCancelled else { return }

        // Phase 4: Clean up
        viewModel.isHealingAnimation = false
        feedingAnimator.stop()
        updateAnimation()
    }
}
