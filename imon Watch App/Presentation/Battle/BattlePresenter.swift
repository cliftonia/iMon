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
        let opponent = BattleOpponent.generate(
            matching: petState
        )
        viewModel.petSpecies = petState.species
        viewModel.opponentSpecies = opponent.species
        viewModel.phase = .intro

        Task {
            await runIntroPhase()
            await runApproachPhase(opponent: opponent)
            await runClashPhase(opponent: opponent)
            showResult(opponent: opponent)
        }
    }

    // MARK: - Battle Phases

    private func runIntroPhase() async {
        try? await Task.sleep(for: .seconds(1.5))
    }

    private func runApproachPhase(
        opponent: BattleOpponent
    ) async {
        viewModel.phase = .approach
        petAnimator.play(
            SpriteCatalog.animation(
                for: petState.species, kind: .idle
            )
        )
        opponentAnimator.play(
            SpriteCatalog.animation(
                for: opponent.species, kind: .idle
            )
        )
        WKInterfaceDevice.battleHaptic()
        try? await Task.sleep(for: .seconds(1.5))
    }

    private func runClashPhase(
        opponent: BattleOpponent
    ) async {
        viewModel.phase = .clash
        petAnimator.play(
            SpriteCatalog.animation(
                for: petState.species, kind: .attack
            )
        )
        opponentAnimator.play(
            SpriteCatalog.animation(
                for: opponent.species, kind: .attack
            )
        )
        WKInterfaceDevice.battleHaptic()
        try? await Task.sleep(for: .seconds(2))
    }

    private func showResult(opponent: BattleOpponent) {
        let result = BattleEngine.battle(
            petState: petState, opponent: opponent
        )
        viewModel.result = result
        viewModel.phase = .result

        switch result {
        case .win:
            petAnimator.play(
                SpriteCatalog.animation(
                    for: petState.species, kind: .happy
                )
            )
            opponentAnimator.stop()
            WKInterfaceDevice.battleWinHaptic()
        case .lose:
            petAnimator.stop()
            opponentAnimator.play(
                SpriteCatalog.animation(
                    for: opponent.species, kind: .happy
                )
            )
            WKInterfaceDevice.battleLoseHaptic()
        case .draw:
            petAnimator.play(
                SpriteCatalog.animation(
                    for: petState.species, kind: .idle
                )
            )
            opponentAnimator.play(
                SpriteCatalog.animation(
                    for: opponent.species, kind: .idle
                )
            )
            WKInterfaceDevice.buttonHaptic()
        }

        onComplete(result)
    }
}
