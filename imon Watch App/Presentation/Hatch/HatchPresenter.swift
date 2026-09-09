import Foundation
import WatchKit

/// Drives the hatch ceremony: a fixed egg → crack → newborn timeline that runs
/// once from `startHatching` and ends by calling `onHatched`. Purely visual —
/// the newborn `PetState` is only created and persisted by `AppPresenter`
/// after the callback, so abandoning the ceremony loses nothing.
final class HatchPresenter {

    /// Carries the current hatch phase shown to the view; only `startHatching` writes it.
    private(set) var viewModel = HatchViewModel()

    /// Plays the sprite loops for each phase; stopped when the ceremony ends.
    let spriteAnimator = SpriteAnimator()

    private let onHatched: () -> Void

    // MARK: - Init

    /// Creates the presenter; `onHatched` fires once the hatch ceremony ends.
    init(onHatched: @escaping () -> Void) {
        self.onHatched = onHatched
    }

    // MARK: - Actions

    /// Runs the ceremony's egg → crack → newborn timeline, then stops the
    /// sprite animator and calls `onHatched` — asynchronously, roughly five
    /// and a half seconds after this returns.
    func startHatching() {
        viewModel.phase = .egg
        spriteAnimator.play(SharedSprites.egg)

        Task {
            try? await Task.sleep(for: .seconds(2))

            viewModel.phase = .cracking
            spriteAnimator.play(SharedSprites.eggCrack)
            WKInterfaceDevice.hatchHaptic()

            try? await Task.sleep(for: .seconds(2))

            viewModel.phase = .hatched
            spriteAnimator.play(.happy, for: .dotkin)

            try? await Task.sleep(for: .seconds(1.5))

            spriteAnimator.stop()
            onHatched()
        }
    }
}
