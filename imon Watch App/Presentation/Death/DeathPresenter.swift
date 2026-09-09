import Foundation
import WatchKit

/// The grave screen's presenter: a static memorial of the fallen pet's name
/// and age, captured at init since the save is deleted on restart. Its single
/// action forwards through `onRestart`, where `AppPresenter` wipes the save
/// and begins a fresh egg.
final class DeathPresenter {

    /// The screen's state: the memorial's name and age, captured at init.
    private(set) var viewModel = DeathViewModel()
    /// The grave sprite's animator, loaded with the still frame at init.
    let spriteAnimator = SpriteAnimator()

    private let onRestart: () -> Void

    // MARK: - Init

    /// Creates the memorial from the pet's final state and plays the grave
    /// sprite.
    init(state: PetState, onRestart: @escaping () -> Void) {
        self.onRestart = onRestart
        viewModel.speciesName = state.species.displayName
        viewModel.ageDays = state.age
        spriteAnimator.play(
            SpriteAnimation.still(SharedSprites.grave)
        )
    }

    // MARK: - Actions

    /// Forwards the restart tap to the injected `onRestart` closure.
    func restartAction() {
        onRestart()
    }
}
