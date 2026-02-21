import Foundation
import WatchKit

final class DeathPresenter {

    private(set) var viewModel = DeathViewModel()
    let spriteAnimator = SpriteAnimator()

    private let onRestart: () -> Void

    // MARK: - Init

    init(state: PetState, onRestart: @escaping () -> Void) {
        self.onRestart = onRestart
        viewModel.speciesName = state.species.displayName
        viewModel.ageDays = state.age
        spriteAnimator.play(
            SpriteAnimation.still(SharedSprites.grave)
        )
    }

    // MARK: - Actions

    func restartAction() {
        onRestart()
    }
}
