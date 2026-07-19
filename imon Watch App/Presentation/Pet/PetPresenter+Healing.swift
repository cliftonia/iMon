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
        startActivity { await $0.runHealingSequence() }
    }

    func runRefuseSequence() async {
        viewModel.activity = .refusing

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

        feedingAnimator.play(SharedSprites.needleInjection)
        WKInterfaceDevice.healHaptic()

        guard await pause(ms: 1200) else { return }

        state = HealAction.apply(to: state)
        updateViewModel()
        save()

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
