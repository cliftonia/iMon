import Foundation
import WatchKit

final class OnboardingPresenter {

    private(set) var viewModel = OnboardingViewModel()
    let spriteAnimator = SpriteAnimator()

    /// Called when the walkthrough is finished or skipped - hands off to play.
    private let onComplete: () -> Void

    // MARK: - Init

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
        playCurrentTip()
    }

    // MARK: - Actions

    /// Advances to the next tip, or finishes on the last one.
    func advanceAction() {
        guard !viewModel.isLastStep else {
            onComplete()
            return
        }
        viewModel.index += 1
        playCurrentTip()
        WKInterfaceDevice.current().play(.click)
    }

    /// Jumps straight to play, skipping the rest of the walkthrough.
    func skipAction() {
        onComplete()
    }

    // MARK: - Private

    private func playCurrentTip() {
        spriteAnimator.play(viewModel.currentTip.animation, for: .dotkin)
    }
}
