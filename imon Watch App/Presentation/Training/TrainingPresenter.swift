import Foundation
import WatchKit

final class TrainingPresenter {

    private(set) var viewModel = TrainingViewModel()
    let spriteAnimator = SpriteAnimator()
    let targetAnimator = SpriteAnimator()

    private let species: DigimonSpecies
    private let onComplete: (Bool) -> Void

    // MARK: - Computed

    var petFrame: SpriteFrame { spriteAnimator.currentFrame }
    var targetFrame: SpriteFrame { targetAnimator.currentFrame }

    // MARK: - Init

    init(
        species: DigimonSpecies,
        onComplete: @escaping (Bool) -> Void
    ) {
        self.species = species
        self.onComplete = onComplete
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

    func nextRound() {
        viewModel.showingNumber = false
        viewModel.currentNumber = TrainAction.generateNumber()
        enterReady()
    }

    // MARK: - Phase Machine

    private func enterReady() {
        viewModel.phase = .ready
        spriteAnimator.play(
            SpriteCatalog.animation(for: species, kind: .walk)
        )
        targetAnimator.stop()

        Task {
            try? await Task.sleep(for: .milliseconds(600))
            guard viewModel.phase == .ready else { return }
            enterChallenge()
        }
    }

    private func enterChallenge() {
        viewModel.phase = .challenge
        spriteAnimator.play(
            SpriteCatalog.animation(for: species, kind: .idle)
        )
    }

    private func enterAttacking(won: Bool) {
        viewModel.phase = .attacking
        spriteAnimator.play(
            SpriteCatalog.animation(for: species, kind: .attack)
                .withFrameDuration(0.2)
        )
        WKInterfaceDevice.battleHaptic()

        Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard viewModel.phase == .attacking else { return }
            enterProjectile(won: won)
        }
    }

    private func enterProjectile(won: Bool) {
        viewModel.phase = .projectile
        let animation = SpriteCatalog.projectile(
            for: species,
            high: viewModel.lastGuessHigh
        )
        spriteAnimator.play(animation)

        Task {
            try? await Task.sleep(for: .milliseconds(700))
            guard viewModel.phase == .projectile else { return }
            if won {
                enterHit()
            } else {
                enterMiss()
            }
        }
    }

    private func enterHit() {
        viewModel.phase = .hit
        spriteAnimator.play(
            SpriteCatalog.animation(for: species, kind: .happy)
        )
        targetAnimator.play(SharedSprites.trainingHitSequence)
        WKInterfaceDevice.trainingHitHaptic()

        Task {
            try? await Task.sleep(for: .milliseconds(800))
            guard viewModel.phase == .hit else { return }
            advanceOrComplete()
        }
    }

    private func enterMiss() {
        viewModel.phase = .miss
        spriteAnimator.play(
            SpriteCatalog.animation(for: species, kind: .idle)
        )
        targetAnimator.play(SharedSprites.trainingMissSequence)
        WKInterfaceDevice.trainingMissHaptic()

        Task {
            try? await Task.sleep(for: .milliseconds(800))
            guard viewModel.phase == .miss else { return }
            advanceOrComplete()
        }
    }

    private func advanceOrComplete() {
        let roundsPlayed = viewModel.roundResults.count
        let wins = viewModel.roundResults.filter { $0 }.count
        let losses = roundsPlayed - wins
        let maxLosses = TimeConstants.trainRounds
            - TimeConstants.trainWinsNeeded

        if wins >= TimeConstants.trainWinsNeeded {
            viewModel.isComplete = true
            viewModel.didWinSession = true
            enterVictory()
            onComplete(true)
        } else if losses > maxLosses {
            viewModel.isComplete = true
            viewModel.didWinSession = false
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
            SpriteCatalog.animation(for: species, kind: .happy)
        )
        targetAnimator.play(SharedSprites.trainingVictorySparkle)
        WKInterfaceDevice.trainingWinHaptic()
    }

    private func enterDefeat() {
        viewModel.phase = .defeat
        spriteAnimator.play(
            SpriteCatalog.animation(for: species, kind: .sleep)
                .withFrameDuration(0.8)
                .withLoops(true)
        )
        targetAnimator.stop()
        WKInterfaceDevice.trainingLoseHaptic()
    }
}
