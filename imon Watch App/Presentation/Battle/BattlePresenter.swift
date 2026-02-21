import Foundation
import WatchKit

final class BattlePresenter {

    private(set) var viewModel = BattleViewModel()
    let petAnimator = SpriteAnimator()
    let opponentAnimator = SpriteAnimator()

    private let petState: PetState
    private let onComplete: (BattleResult) -> Void

    // MARK: - Init

    init(
        petState: PetState,
        onComplete: @escaping (BattleResult) -> Void
    ) {
        self.petState = petState
        self.onComplete = onComplete
    }

    // MARK: - Computed

    var petFrame: SpriteFrame { petAnimator.currentFrame }

    var opponentFrame: SpriteFrame {
        opponentAnimator.currentFrame.mirrored()
    }

    // MARK: - Actions

    func startBattle() {
        let opponent = BattleOpponent.generate(matching: petState)
        viewModel.petSpecies = petState.species
        viewModel.opponentSpecies = opponent.species
        viewModel.phase = .intro

        Task {
            // Intro: VS screen
            try? await Task.sleep(for: .seconds(1.5))

            // Approach: both idle on LCD facing each other
            viewModel.phase = .approach
            petAnimator.play(
                SpriteCatalog.animation(
                    for: petState.species,
                    kind: .idle
                )
            )
            opponentAnimator.play(
                SpriteCatalog.animation(
                    for: opponent.species,
                    kind: .idle
                )
            )
            WKInterfaceDevice.battleHaptic()
            try? await Task.sleep(for: .seconds(1.5))

            // Clash: attack animations
            viewModel.phase = .clash
            petAnimator.play(
                SpriteCatalog.animation(
                    for: petState.species,
                    kind: .attack
                )
            )
            opponentAnimator.play(
                SpriteCatalog.animation(
                    for: opponent.species,
                    kind: .attack
                )
            )
            WKInterfaceDevice.battleHaptic()
            try? await Task.sleep(for: .seconds(2))

            // Calculate result
            let result = BattleEngine.battle(
                petState: petState,
                opponent: opponent
            )
            viewModel.result = result
            viewModel.phase = .result

            // Result animations
            switch result {
            case .win:
                petAnimator.play(
                    SpriteCatalog.animation(
                        for: petState.species,
                        kind: .happy
                    )
                )
                opponentAnimator.stop()
                WKInterfaceDevice.battleWinHaptic()
            case .lose:
                petAnimator.stop()
                opponentAnimator.play(
                    SpriteCatalog.animation(
                        for: opponent.species,
                        kind: .happy
                    )
                )
                WKInterfaceDevice.battleLoseHaptic()
            case .draw:
                petAnimator.play(
                    SpriteCatalog.animation(
                        for: petState.species,
                        kind: .idle
                    )
                )
                opponentAnimator.play(
                    SpriteCatalog.animation(
                        for: opponent.species,
                        kind: .idle
                    )
                )
                WKInterfaceDevice.buttonHaptic()
            }

            onComplete(result)
        }
    }
}
