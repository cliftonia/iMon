import Foundation
import WatchKit

/// Drives the grave screen: a static memorial of the fallen pet's name and age,
/// captured at init since the save is deleted on restart. Its single action
/// forwards through `onRestart`, where `AppPresenter` wipes the save and
/// begins a fresh egg.
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
