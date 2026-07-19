import Foundation
import WatchKit

/// Runs one battle ceremony from intro to outcome: owns the phase state, both
/// sprite animators, and the async round loop. Spawned fresh per battle by
/// `PetPresenter.startBattleMode` and reports the result once via `onComplete`;
/// `cancelBattle` must run on dismissal so a pending pick continuation is
/// resumed rather than leaked.
final class BattlePresenter {

    private(set) var viewModel = BattleViewModel()
    let petAnimator = SpriteAnimator()
    let opponentAnimator = SpriteAnimator()

    // Read by the `+Frames` and `+Rounds` extensions.
    let petState: PetState
    let steps: Int?
    let onComplete: (BattleResult) -> Void
    var opponent: BattleOpponent?
    var pickContinuation: CheckedContinuation<AttackHeight, Never>?

    private var battleTask: Task<Void, Never>?

    // MARK: - Init

    init(
        petState: PetState,
        steps: Int?,
        onComplete: @escaping (BattleResult) -> Void
    ) {
        self.petState = petState
        self.steps = steps
        self.onComplete = onComplete
    }

    // MARK: - Actions

    func startBattle() {
        let opp = BattleOpponent.generate(matching: petState)
        self.opponent = opp

        viewModel.petSpecies = petState.species
        viewModel.opponentSpecies = opp.species

        let petHP = BattleHP.calculate(for: petState, steps: steps)
        viewModel.petHP = petHP
        viewModel.petMaxHP = petHP

        let oppHP = opp.species.stage.battleHP
        viewModel.opponentHP = oppHP
        viewModel.opponentMaxHP = oppHP
        viewModel.phase = .introPet
        petAnimator.play(.idle, for: petState.species)

        battleTask = Task { [weak self] in
            await self?.runBattle()
        }
    }

    func pickAction(_ height: AttackHeight) {
        guard viewModel.phase == .choosing else { return }
        pickContinuation?.resume(returning: height)
        pickContinuation = nil
    }

    /// Tears down an abandoned battle: cancels the loop and resumes any pending
    /// pick continuation (a `CheckedContinuation` must be resumed exactly once,
    /// or it leaks the suspended task forever).
    func cancelBattle() {
        battleTask?.cancel()
        battleTask = nil
        pickContinuation?.resume(returning: .medium)
        pickContinuation = nil
    }

    // MARK: - Battle Loop

    private func runBattle() async {
        await runIntro()
        guard !Task.isCancelled else { return }

        await runRoundLoop()
    }

    /// Opening beats: our monster, a "VS" flash, then the opponent.
    private func runIntro() async {
        // Our monster is already on screen from `startBattle` — just hold the beat.
        try? await Task.sleep(for: .seconds(Self.introSceneDuration))
        guard !Task.isCancelled, let opp = opponent else { return }

        // The LCD flash layer draws the strobing "VS" — nothing to animate here.
        viewModel.phase = .introVS
        WKInterfaceDevice.battleHaptic()
        try? await Task.sleep(for: .seconds(Self.introVSDuration))
        guard !Task.isCancelled else { return }

        viewModel.phase = .introEnemy
        opponentAnimator.play(.idle, for: opp.species)
        try? await Task.sleep(for: .seconds(Self.introSceneDuration))
    }

    private static let introSceneDuration = 1.3
    private static let introVSDuration = 1.3

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
