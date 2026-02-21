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
}
