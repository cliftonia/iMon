import Foundation
import WatchKit

final class HatchPresenter {

    private(set) var viewModel = HatchViewModel()
    let spriteAnimator = SpriteAnimator()

    private let onHatched: () -> Void

    // MARK: - Init

    init(onHatched: @escaping () -> Void) {
        self.onHatched = onHatched
    }

    // MARK: - Actions

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
            spriteAnimator.play(
                SpriteCatalog.animation(for: .botamon, kind: .happy)
            )

            try? await Task.sleep(for: .seconds(1.5))

            onHatched()
        }
    }
}
