import Testing
import Foundation
@testable import imon_Watch_App

@Suite("BattleEngine")
struct BattleEngineTests {

    @Test
    func `battle returns a valid result`() {
        let state = makeTestState(
            species: .rexkin, strength: 4, weight: 30
        )
        let opponent = BattleOpponent.generate(
            matching: state
        )
        let result = BattleEngine.battle(
            petState: state, opponent: opponent
        )
        #expect(
            [BattleResult.win, .lose, .draw].contains(result)
        )
    }

    @Test
    func `apply result increments win count`() {
        var state = makeTestState()
        state.battleWins = 0
        state = BattleEngine.applyResult(.win, to: state)
        #expect(state.battleWins == 1)
    }

    @Test
    func `apply result increments loss count`() {
        var state = makeTestState()
        state.battleLosses = 0
        state = BattleEngine.applyResult(.lose, to: state)
        #expect(state.battleLosses == 1)
    }

    // MARK: - Conditioning (trained POW)

    @Test
    func `winning a battle builds trained POW up to the cap`() {
        var state = makeTestState(species: .emberkin)
        state = BattleEngine.applyResult(.win, to: state)
        #expect(state.trainedPower == 1)
        for _ in 0..<10 {
            state = BattleEngine.applyResult(.win, to: state)
        }
        #expect(state.trainedPower == TimeConstants.maxConditioning)
    }

    @Test
    func `Dotkin never builds trained POW`() {
        var state = makeTestState(species: .dotkin)
        for _ in 0..<5 {
            state = BattleEngine.applyResult(.win, to: state)
        }
        #expect(state.trainedPower == 0)
    }

    @Test
    func `every battle stamps last-battled but a loss grants no POW`() {
        let now = Date(timeIntervalSince1970: 5_000)
        var state = makeTestState(species: .emberkin)
        state = BattleEngine.applyResult(.lose, to: state, at: now)
        #expect(state.trainedPower == 0)
        #expect(state.timestamps.lastBattledAt == now)
    }

    @Test
    func `trained HP raises battle HP`() {
        var state = makeTestState(species: .emberkin)
        let base = BattleHP.calculate(for: state)
        state.trainedHP = 2
        #expect(BattleHP.calculate(for: state) == base + 2)
    }

    // MARK: - canBattle

    @Test
    func `canBattle true for healthy awake pet`() {
        let state = makeTestState()
        #expect(BattleEngine.canBattle(state))
    }

    @Test
    func `canBattle false when sleeping`() {
        var state = makeTestState()
        state.isSleeping = true
        #expect(!BattleEngine.canBattle(state))
    }

    @Test
    func `canBattle false when dead`() {
        var state = makeTestState()
        state.isDead = true
        #expect(!BattleEngine.canBattle(state))
    }

    @Test
    func `canBattle false when egg`() {
        var state = makeTestState()
        state.isEgg = true
        #expect(!BattleEngine.canBattle(state))
    }

    // MARK: - resolveRound

    @Test
    func `resolveRound returns playerHit when player height wins`() {
        let outcome = BattleEngine.resolveRound(
            playerHeight: .high,
            opponentHeight: .medium
        )
        #expect(outcome == .playerHit)
    }

    @Test
    func `resolveRound returns opponentHit when opponent height wins`() {
        let outcome = BattleEngine.resolveRound(
            playerHeight: .high,
            opponentHeight: .low
        )
        #expect(outcome == .opponentHit)
    }

    @Test
    func `resolveRound same height is always clash`() {
        let outcome = BattleEngine.resolveRound(
            playerHeight: .medium,
            opponentHeight: .medium
        )
        #expect(outcome == .clash)
    }

    // MARK: - effectivePower

    @Test
    func `effectivePower applies attribute advantage`() {
        let power = BattleEngine.effectivePower(
            basePower: 100,
            attribute: .vaccine,
            against: .virus
        )
        #expect(power == 120)
    }

    @Test
    func `effectivePower no bonus without advantage`() {
        let power = BattleEngine.effectivePower(
            basePower: 100,
            attribute: .vaccine,
            against: .data
        )
        #expect(power == 100)
    }

    // MARK: - BattleHP

    @Test
    func `HP is the species base HP`() {
        // Dotkin baseHP 2, Emberkin 4, Steelkin 5 — independent of hunger/strength.
        #expect(BattleHP.calculate(for: makeTestState(species: .dotkin)) == 2)
        #expect(BattleHP.calculate(for: makeTestState(species: .emberkin)) == 4)
        #expect(BattleHP.calculate(for: makeTestState(species: .steelkin)) == 5)
        #expect(BattleHP.calculate(for: makeTestState(species: .plushkin)) == 7)
    }

    @Test
    func `opponent gets base HP from stage`() {
        #expect(EvolutionStage.ultimate.battleHP == 5)
        #expect(EvolutionStage.rookie.battleHP == 3)
        #expect(EvolutionStage.fresh.battleHP == 1)
    }

    // MARK: - applyResult edge cases

    @Test
    func `apply result draw does not change counts`() {
        var state = makeTestState()
        state.battleWins = 2
        state.battleLosses = 1
        state = BattleEngine.applyResult(.draw, to: state)
        #expect(state.battleWins == 2)
        #expect(state.battleLosses == 1)
    }

    // MARK: - BattleHP stages

    @Test(arguments: [
        (PetSpecies.dotkin, 2),
        (PetSpecies.hopkin, 3),
        (PetSpecies.emberkin, 4),
        (PetSpecies.rexkin, 4),
        (PetSpecies.steelkin, 5)
    ])
    func `BattleHP matches species base HP`(
        species: PetSpecies,
        expectedHP: Int
    ) {
        let state = makeTestState(species: species)
        #expect(BattleHP.calculate(for: state) == expectedHP)
    }

    // MARK: - BattleOpponent

    @Test
    func `opponent is generated with same stage`() {
        let state = makeTestState(species: .rexkin)
        let opp = BattleOpponent.generate(matching: state)
        #expect(opp.species.stage == state.species.stage)
    }

    @Test
    func `opponent has positive power`() {
        let state = makeTestState(species: .emberkin)
        let opp = BattleOpponent.generate(matching: state)
        #expect(opp.power > 0)
    }

    @Test(arguments: PetSpecies.allCases)
    func `opponent is never the same species`(
        species: PetSpecies
    ) {
        let state = makeTestState(species: species)
        for _ in 0..<50 {
            let opp = BattleOpponent.generate(matching: state)
            #expect(opp.species != species)
        }
    }

    // MARK: - heartsString

    @Test
    func `heartsString full HP shows all filled`() {
        let result = BattleHP.heartsString(hp: 3, maxHP: 3)
        #expect(result == "\u{2665}\u{2665}\u{2665}")
    }

    @Test
    func `heartsString zero HP shows all empty`() {
        let result = BattleHP.heartsString(hp: 0, maxHP: 3)
        #expect(result == "\u{2661}\u{2661}\u{2661}")
    }

    @Test
    func `heartsString partial HP shows mixed`() {
        let result = BattleHP.heartsString(hp: 2, maxHP: 5)
        #expect(
            result == "\u{2665}\u{2665}\u{2661}\u{2661}\u{2661}"
        )
    }

    @Test
    func `heartsString hp exceeding maxHP clamps empty to zero`() {
        let result = BattleHP.heartsString(hp: 5, maxHP: 3)
        #expect(result == "\u{2665}\u{2665}\u{2665}\u{2665}\u{2665}")
    }

    // MARK: - battleHP all stages covered

    @Test(arguments: EvolutionStage.allCases)
    func `battleHP returns positive value for all stages`(
        stage: EvolutionStage
    ) {
        #expect(stage.battleHP > 0)
    }

    @Test
    func `battleHP increases with stage`() {
        let stages = EvolutionStage.allCases.sorted()
        for i in 1..<stages.count {
            #expect(stages[i].battleHP >= stages[i - 1].battleHP)
        }
    }
}
