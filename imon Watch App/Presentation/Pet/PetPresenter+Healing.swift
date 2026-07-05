import Foundation
import WatchKit

extension PetPresenter {

    // MARK: - Healing (Inline LCD Ceremony)

    func healAction() {
        guard !viewModel.isBusy else { return }
        guard HealAction.canHeal(state) else {
            refuse()
            return
        }
        activityTask?.cancel()
        activityTask = Task { [weak self] in
            await self?.runHealingSequence()
        }
    }

    func runRefuseSequence() async {
        viewModel.activity = .refusing

        // Head shake only
        spriteAnimator.play(
            SpriteCatalog.animation(
                for: state.species, kind: .refuse
            )
        )
        WKInterfaceDevice.rejectHaptic()

        guard await pause(ms: 800) else { return }

        endActivity()
    }

    func runHealingSequence() async {
        viewModel.activity = .healing

        // Phase 1: Needle injection (1200ms)
        feedingAnimator.play(SharedSprites.needleInjection)
        WKInterfaceDevice.healHaptic()

        guard await pause(ms: 1200) else { return }

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

        guard await pause(ms: 1000) else { return }

        endActivity()
    }
}
