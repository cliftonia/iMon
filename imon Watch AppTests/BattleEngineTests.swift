import Testing
@testable import imon_Watch_App

@Suite("BattleEngine")
struct BattleEngineTests {

    @Test
    func `battle returns a valid result`() {
        let state = makeTestState(
            species: .greymon, strength: 4, weight: 30
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
    func `fresh pet with empty stats has 1 HP`() {
        let state = makeTestState(
            species: .botamon, hunger: 0, strength: 0
        )
        #expect(BattleHP.calculate(for: state) == 1)
    }

    @Test
    func `rookie pet with full stats has 5 HP`() {
        let state = makeTestState(
            species: .agumon, hunger: 4, strength: 4
        )
        #expect(BattleHP.calculate(for: state) == 5)
    }

    @Test
    func `ultimate pet with full stats has 7 HP`() {
        let state = makeTestState(
            species: .metalGreymon, hunger: 4, strength: 4
        )
        #expect(BattleHP.calculate(for: state) == 7)
    }

    @Test
    func `opponent gets base HP only from stage`() {
        #expect(EvolutionStage.ultimate.battleHP == 5)
        #expect(EvolutionStage.rookie.battleHP == 3)
        #expect(EvolutionStage.fresh.battleHP == 1)
    }

    @Test
    func `hunger bonus requires at least 3 hearts`() {
        let below = makeTestState(
            species: .agumon, hunger: 2, strength: 0
        )
        let atThreshold = makeTestState(
            species: .agumon, hunger: 3, strength: 0
        )
        #expect(BattleHP.calculate(for: below) == 3)
        #expect(BattleHP.calculate(for: atThreshold) == 4)
    }

    @Test
    func `strength bonus requires at least 3 hearts`() {
        let below = makeTestState(
            species: .agumon, hunger: 0, strength: 2
        )
        let atThreshold = makeTestState(
            species: .agumon, hunger: 0, strength: 3
        )
        #expect(BattleHP.calculate(for: below) == 3)
        #expect(BattleHP.calculate(for: atThreshold) == 4)
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
        (DigimonSpecies.botamon, 0, 0, 1),
        (DigimonSpecies.koromon, 0, 0, 2),
        (DigimonSpecies.agumon, 0, 0, 3),
        (DigimonSpecies.greymon, 0, 0, 4),
        (DigimonSpecies.metalGreymon, 0, 0, 5)
    ])
    func `BattleHP base matches stage`(
        species: DigimonSpecies,
        hunger: Int,
        strength: Int,
        expectedHP: Int
    ) {
        let state = makeTestState(
            species: species,
            hunger: hunger,
            strength: strength
        )
        #expect(BattleHP.calculate(for: state) == expectedHP)
    }

    // MARK: - BattleOpponent

    @Test
    func `opponent is generated with same stage`() {
        let state = makeTestState(species: .greymon)
        let opp = BattleOpponent.generate(matching: state)
        #expect(opp.species.stage == state.species.stage)
    }

    @Test
    func `opponent has positive power`() {
        let state = makeTestState(species: .agumon)
        let opp = BattleOpponent.generate(matching: state)
        #expect(opp.power > 0)
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
