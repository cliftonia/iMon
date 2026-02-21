import Foundation
import WatchKit

extension PetPresenter {

    // MARK: - Healing (Inline LCD Ceremony)

    func healAction() {
        guard !viewModel.isBusy else { return }
        guard HealAction.canHeal(state) else {
            refuseTask?.cancel()
            refuseTask = Task { [weak self] in
                await self?.runRefuseSequence()
            }
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
        refuseTask?.cancel()
        refuseTask = nil
        viewModel.isHealingAnimation = false
        feedingAnimator.stop()
        updateAnimation()
    }

    func runRefuseSequence() async {
        viewModel.isHealingAnimation = true

        // Head shake only
        spriteAnimator.play(
            SpriteCatalog.animation(
                for: state.species, kind: .refuse
            )
        )
        WKInterfaceDevice.rejectHaptic()

        try? await Task.sleep(for: .milliseconds(800))
        guard !Task.isCancelled else { return }

        viewModel.isHealingAnimation = false
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
