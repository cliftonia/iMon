import Foundation
import WatchKit

final class TrainingPresenter {

    private(set) var viewModel = TrainingViewModel()
    let spriteAnimator = SpriteAnimator()
    let targetAnimator = SpriteAnimator()

    private let species: PetSpecies
    private let onComplete: (Bool) -> Void

    /// The single in-flight phase-advance timer, so it can be cancelled on
    /// dismiss instead of firing into a torn-down presenter.
    private var phaseTask: Task<Void, Never>?

    // MARK: - Computed

    var petFrame: SpriteFrame { spriteAnimator.currentFrame }
    var targetFrame: SpriteFrame { targetAnimator.currentFrame }

    // MARK: - Init

    init(
        species: PetSpecies,
        onComplete: @escaping (Bool) -> Void
    ) {
        self.species = species
        self.onComplete = onComplete
    }

    /// Cancels any pending phase advance — called when training is dismissed.
    func cancel() {
        phaseTask?.cancel()
        phaseTask = nil
    }

    /// Schedules the next phase after a delay, replacing any pending one. Captures
    /// `self` weakly so a dismissed presenter can deallocate immediately.
    private func schedule(after milliseconds: Int, _ advance: @escaping (TrainingPresenter) -> Void) {
        phaseTask?.cancel()
        phaseTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(milliseconds))
            guard let self, !Task.isCancelled else { return }
            advance(self)
        }
    }

    // MARK: - Actions

    func startTraining() {
        viewModel = TrainingViewModel()
        viewModel.currentNumber = TrainAction.generateNumber()
        enterReady()
    }

    func guessAction(_ guess: TrainAction.Guess) {
        guard viewModel.phase == .challenge else { return }

        let result = TrainAction.evaluateRound(
            number: viewModel.currentNumber,
            guess: guess
        )
        viewModel.showingNumber = true
        viewModel.roundResults.append(result.won)
        viewModel.lastGuessHigh = guess == .high

        enterAttacking(won: result.won)
    }

    // MARK: - Phase Machine

    private func enterReady() {
        viewModel.phase = .ready
        // Face front while waiting — only turn side-on once the player attacks.
        spriteAnimator.play(.idle, for: species)
        targetAnimator.stop()

        schedule(after: 600) { presenter in
            guard presenter.viewModel.phase == .ready else { return }
            presenter.enterChallenge()
        }
    }

    private func enterChallenge() {
        viewModel.phase = .challenge
        // Still facing front — the player hasn't chosen high or low yet.
        spriteAnimator.play(.idle, for: species)
    }

    private func enterAttacking(won: Bool) {
        viewModel.phase = .attacking
        spriteAnimator.play(
            SpriteCatalog.sideAttack(for: species).facing(.right)
        )
        WKInterfaceDevice.battleHaptic()

        schedule(after: 500) { presenter in
            guard presenter.viewModel.phase == .attacking else { return }
            presenter.enterProjectile(won: won)
        }
    }

    private func enterProjectile(won: Bool) {
        viewModel.phase = .projectile
        let height: AttackHeight = viewModel.lastGuessHigh
            ? .high : .low
        let animation = SpriteCatalog.projectile(
            for: species,
            height: height
        )
        spriteAnimator.play(animation)

        schedule(after: 700) { presenter in
            guard presenter.viewModel.phase == .projectile else { return }
            if won {
                presenter.enterHit()
            } else {
                presenter.enterMiss()
            }
        }
    }

    private func enterHit() {
        viewModel.phase = .hit
        spriteAnimator.play(
            SpriteCatalog.animation(for: species, kind: .happy).facing(.right)
        )
        targetAnimator.play(SharedSprites.trainingHitSequence)
        WKInterfaceDevice.trainingHitHaptic()

        schedule(after: 800) { presenter in
            guard presenter.viewModel.phase == .hit else { return }
            presenter.advanceOrComplete()
        }
    }

    private func enterMiss() {
        viewModel.phase = .miss
        spriteAnimator.play(
            SpriteCatalog.sideStance(for: species).facing(.right)
        )
        targetAnimator.play(SharedSprites.missStreaks)
        WKInterfaceDevice.trainingMissHaptic()

        schedule(after: 800) { presenter in
            guard presenter.viewModel.phase == .miss else { return }
            presenter.advanceOrComplete()
        }
    }

    private func advanceOrComplete() {
        let roundsPlayed = viewModel.roundResults.count
        let wins = viewModel.roundResults.filter { $0 }.count
        let losses = roundsPlayed - wins
        let maxLosses = TimeConstants.trainRounds
            - TimeConstants.trainWinsNeeded

        if wins >= TimeConstants.trainWinsNeeded {
            enterVictory()
            onComplete(true)
        } else if losses > maxLosses {
            enterDefeat()
            onComplete(false)
        } else {
            viewModel.currentRound = roundsPlayed
            // Auto-advance to next round
            viewModel.showingNumber = false
            viewModel.currentNumber = TrainAction.generateNumber()
            enterReady()
        }
    }

    private func enterVictory() {
        viewModel.phase = .victory
        spriteAnimator.play(
            SpriteCatalog.animation(for: species, kind: .happy).facing(.right)
        )
        targetAnimator.play(SharedSprites.trainingVictorySparkle)
        WKInterfaceDevice.trainingWinHaptic()
    }

    private func enterDefeat() {
        viewModel.phase = .defeat
        spriteAnimator.play(
            SpriteCatalog.defeatAnimation(for: species).facing(.right)
        )
        targetAnimator.stop()
        WKInterfaceDevice.trainingLoseHaptic()
    }
}
