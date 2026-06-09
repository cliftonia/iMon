import Foundation
import WatchKit

final class BattlePresenter {

    private(set) var viewModel = BattleViewModel()
    let petAnimator = SpriteAnimator()
    let opponentAnimator = SpriteAnimator()

    // Read by the `+Frames` and `+Rounds` extensions.
    let petState: PetState
    let onComplete: (BattleResult) -> Void
    var opponent: BattleOpponent?
    var pickContinuation: CheckedContinuation<AttackHeight, Never>?

    private var battleTask: Task<Void, Never>?

    // MARK: - Init

    init(
        petState: PetState,
        onComplete: @escaping (BattleResult) -> Void
    ) {
        self.petState = petState
        self.onComplete = onComplete
    }

    // MARK: - Actions

    func startBattle() {
        let opp = BattleOpponent.generate(matching: petState)
        self.opponent = opp

        viewModel.petSpecies = petState.species
        viewModel.opponentSpecies = opp.species

        let petHP = BattleHP.calculate(for: petState)
        viewModel.petHP = petHP
        viewModel.petMaxHP = petHP

        let oppHP = opp.species.stage.battleHP
        viewModel.opponentHP = oppHP
        viewModel.opponentMaxHP = oppHP
        viewModel.lightsOn = petState.lightsOn
        viewModel.phase = .approach

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
        await runApproachPhase()
        guard !Task.isCancelled else { return }

        await runRoundLoop()
    }

    private func runApproachPhase() async {
        viewModel.phase = .approach
        petAnimator.play(.walk, for: petState.species)
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
