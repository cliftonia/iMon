import Foundation
import WatchKit

final class BattlePresenter {

    private(set) var viewModel = BattleViewModel()
    let petAnimator = SpriteAnimator()
    let opponentAnimator = SpriteAnimator()

    private let petState: PetState
    private let onComplete: (BattleResult) -> Void

    private var opponent: BattleOpponent?
    private var petEffectivePower: Double = 0
    private var opponentEffectivePower: Double = 0
    private var battleTask: Task<Void, Never>?
    private var pickContinuation: CheckedContinuation<AttackHeight, Never>?

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

    /// Single active sprite — only one thing on screen at a time.
    var activeFrame: SpriteFrame {
        switch viewModel.phase {
        case .intro:
            return .empty
        case .approach, .choosing, .attacking, .projectile:
            return petFrame
        case .opponentAttacking:
            return opponentFrame
        case .opponentProjectile:
            // No mirror — projectileReversed already goes R→L
            return opponentAnimator.currentFrame
        case .impact:
            switch viewModel.lastRoundOutcome {
            case .playerHit: return opponentFrame
            case .opponentHit, .clash, .none:
                return petAnimator.currentFrame
            }
        case .victory:
            return viewModel.result == .lose
                ? opponentFrame : petFrame
        case .defeat:
            return opponentFrame
        }
    }

    // MARK: - Actions

    func startBattle() {
        let opp = BattleOpponent.generate(matching: petState)
        self.opponent = opp

        let petPower = BattlePower.calculate(for: petState)
        petEffectivePower = BattleEngine.effectivePower(
            basePower: petPower,
            attribute: petState.species.attribute,
            against: opp.attribute
        )
        opponentEffectivePower = BattleEngine.effectivePower(
            basePower: opp.power,
            attribute: opp.attribute,
            against: petState.species.attribute
        )

        viewModel.petSpecies = petState.species
        viewModel.opponentSpecies = opp.species

        let petHP = BattleHP.calculate(for: petState)
        viewModel.petHP = petHP
        viewModel.petMaxHP = petHP

        let oppHP = opp.species.stage.battleHP
        viewModel.opponentHP = oppHP
        viewModel.opponentMaxHP = oppHP
        viewModel.lightsOn = petState.lightsOn
        viewModel.phase = .intro

        battleTask = Task { [weak self] in
            await self?.runBattle()
        }
    }

    func pickAction(_ height: AttackHeight) {
        guard viewModel.phase == .choosing else { return }
        pickContinuation?.resume(returning: height)
        pickContinuation = nil
    }

    // MARK: - Battle Loop

    private func runBattle() async {
        await runIntroPhase()
        guard !Task.isCancelled else { return }

        await runApproachPhase()
        guard !Task.isCancelled else { return }

        await runRoundLoop()
    }

    private func runIntroPhase() async {
        try? await Task.sleep(for: .seconds(2))
    }

    private func runApproachPhase() async {
        viewModel.phase = .approach
        petAnimator.play(
            SpriteCatalog.animation(
                for: petState.species, kind: .walk
            )
        )
        WKInterfaceDevice.battleHaptic()
        try? await Task.sleep(for: .seconds(2))
    }

    private func runRoundLoop() async {
        for _ in 0..<20 {
            guard !Task.isCancelled else { return }

            let completed = await runSingleRound()
            guard completed, !Task.isCancelled else { return }

            if viewModel.opponentHP <= 0 {
                showVictory()
                return
            }
            if viewModel.petHP <= 0 {
                showDefeat()
                return
            }
        }
        resolveTiebreaker()
    }
}

// MARK: - Phase Runners

extension BattlePresenter {

    private func runSingleRound() async -> Bool {
        enterChoosing()
        let playerHeight = await waitForPick()
        guard !Task.isCancelled else { return false }

        let opponentHeight = AttackHeight.allCases
            .randomElement() ?? .medium
        let outcome = BattleEngine.resolveRound(
            playerHeight: playerHeight,
            opponentHeight: opponentHeight
        )
        viewModel.lastRoundOutcome = outcome

        await runAttacking()
        guard !Task.isCancelled else { return false }

        await runProjectile(height: playerHeight)
        guard !Task.isCancelled else { return false }

        await runOpponentAttacking()
        guard !Task.isCancelled else { return false }

        await runOpponentProjectile(height: opponentHeight)
        guard !Task.isCancelled else { return false }

        await runImpact(outcome: outcome)
        return !Task.isCancelled
    }

    private func enterChoosing() {
        viewModel.phase = .choosing
        viewModel.lastRoundOutcome = nil
        petAnimator.play(
            SpriteCatalog.animation(
                for: petState.species, kind: .idle
            )
        )
    }

    private func waitForPick() async -> AttackHeight {
        await withCheckedContinuation { continuation in
            self.pickContinuation = continuation
        }
    }

    private func runAttacking() async {
        viewModel.phase = .attacking
        petAnimator.play(
            SpriteCatalog.animation(
                for: petState.species, kind: .attack
            ).withFrameDuration(0.25)
        )
        WKInterfaceDevice.battleHaptic()
        try? await Task.sleep(for: .milliseconds(800))
    }

    private func runProjectile(height: AttackHeight) async {
        viewModel.phase = .projectile
        petAnimator.play(
            SpriteCatalog.projectile(
                for: petState.species, height: height
            )
        )
        try? await Task.sleep(for: .seconds(1))
    }

    private func runOpponentAttacking() async {
        guard let opp = opponent else { return }
        viewModel.phase = .opponentAttacking
        opponentAnimator.play(
            SpriteCatalog.animation(
                for: opp.species, kind: .attack
            ).withFrameDuration(0.25)
        )
        try? await Task.sleep(for: .milliseconds(800))
    }

    private func runOpponentProjectile(
        height: AttackHeight
    ) async {
        guard let opp = opponent else { return }
        viewModel.phase = .opponentProjectile
        opponentAnimator.play(
            SpriteCatalog.projectileReversed(
                for: opp.species, height: height
            )
        )
        WKInterfaceDevice.battleHaptic()
        try? await Task.sleep(for: .seconds(1))
    }

    private func runImpact(outcome: RoundOutcome) async {
        guard let opp = opponent else { return }
        viewModel.phase = .impact

        switch outcome {
        case .playerHit:
            viewModel.opponentHP -= 1
            let base = SpriteCatalog.frames(
                for: opp.species, kind: .idle
            )[0]
            let hit = SpriteAnimation(
                frames: [
                    base.overlaying(SharedSprites.explosion1),
                    SharedSprites.explosion2,
                    SharedSprites.explosion3,
                    .empty,
                    base
                ],
                frameDuration: 0.25,
                loops: false
            )
            opponentAnimator.play(hit)
            WKInterfaceDevice.battleWinHaptic()

        case .opponentHit:
            viewModel.petHP -= 1
            petAnimator.play(SharedSprites.missStreaks)
            WKInterfaceDevice.battleLoseHaptic()

        case .clash:
            petAnimator.play(SharedSprites.explosion)
            WKInterfaceDevice.buttonHaptic()
        }

        try? await Task.sleep(for: .seconds(1.5))
    }

    private func resolveTiebreaker() {
        switch (viewModel.petHP, viewModel.opponentHP) {
        case let (pet, opp) where pet > opp: showVictory()
        case let (pet, opp) where opp > pet: showDefeat()
        default: showDraw()
        }
    }

    // MARK: - Outcomes

    private func showVictory() {
        viewModel.result = .win
        viewModel.phase = .victory
        petAnimator.play(
            SpriteCatalog.animation(
                for: petState.species, kind: .happy
            )
        )
        opponentAnimator.stop()
        WKInterfaceDevice.battleWinHaptic()
        onComplete(.win)
    }

    private func showDefeat() {
        guard let opp = opponent else { return }
        viewModel.result = .lose
        viewModel.phase = .defeat
        petAnimator.stop()
        opponentAnimator.play(
            SpriteCatalog.animation(
                for: opp.species, kind: .happy
            )
        )
        WKInterfaceDevice.battleLoseHaptic()
        onComplete(.lose)
    }

    private func showDraw() {
        guard let opp = opponent else { return }
        viewModel.result = .draw
        viewModel.phase = .victory
        petAnimator.play(
            SpriteCatalog.animation(
                for: petState.species, kind: .idle
            )
        )
        opponentAnimator.play(
            SpriteCatalog.animation(
                for: opp.species, kind: .idle
            )
        )
        WKInterfaceDevice.buttonHaptic()
        onComplete(.draw)
    }
}
