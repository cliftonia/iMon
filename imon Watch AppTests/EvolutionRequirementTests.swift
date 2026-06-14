import Testing
import Foundation
@testable import imon_Watch_App

@Suite("EvolutionRequirement")
struct EvolutionRequirementTests {

    private func makeReady(at base: Date) -> PetState {
        var state = makeTestState(at: base)
        // Plenty of awake time so only the field under test gates the result.
        state.timestamps.evolvedAt = base.addingTimeInterval(-100_000)
        return state
    }

    @Test
    func `min awake time gates evolution`() {
        let now = Date.now
        var state = makeTestState(at: now)
        state.timestamps.evolvedAt = now   // no time elapsed yet
        let req = EvolutionRequirement(
            from: .emberkin, to: .galekin, minAwakeTime: 3_600
        )
        #expect(req.isSatisfied(by: state, at: now) == false)
    }

    // The zero-battle edge: a win-rate gate must fail when no battles happened.
    @Test
    func `win rate is unmet with no battles`() {
        let now = Date.now
        var state = makeReady(at: now)
        state.battleWins = 0
        state.battleLosses = 0
        let req = EvolutionRequirement(
            from: .emberkin, to: .galekin, minAwakeTime: 0, minWinRate: 0.8
        )
        #expect(req.isSatisfied(by: state, at: now) == false)
    }

    @Test
    func `win rate is met when high enough`() {
        let now = Date.now
        var state = makeReady(at: now)
        state.battleWins = 9
        state.battleLosses = 1
        let req = EvolutionRequirement(
            from: .emberkin, to: .galekin, minAwakeTime: 0, minWinRate: 0.8
        )
        #expect(req.isSatisfied(by: state, at: now))
    }

    @Test
    func `win rate is unmet when too low`() {
        let now = Date.now
        var state = makeReady(at: now)
        state.battleWins = 5
        state.battleLosses = 5
        let req = EvolutionRequirement(
            from: .emberkin, to: .galekin, minAwakeTime: 0, minWinRate: 0.8
        )
        #expect(req.isSatisfied(by: state, at: now) == false)
    }

    @Test
    func `weight and care-mistake bounds gate evolution`() {
        let now = Date.now
        var state = makeReady(at: now)
        state.weight = Weight(50)
        state.careMistakes = 3
        let needsLight = EvolutionRequirement(
            from: .emberkin, to: .galekin, minAwakeTime: 0, maxCareMistakes: 1
        )
        let needsHeavy = EvolutionRequirement(
            from: .emberkin, to: .galekin, minAwakeTime: 0, minWeight: 40
        )
        #expect(needsLight.isSatisfied(by: state, at: now) == false)  // 3 > 1
        #expect(needsHeavy.isSatisfied(by: state, at: now))           // 50 >= 40
    }
}
