import Testing
import Foundation
@testable import imon_Watch_App

@Suite("DeathEvaluator")
struct DeathEvaluatorTests {

    @Test
    func `dies from too many care mistakes`() {
        var state = makeTestState()
        state.careMistakes = 20
        let cause = DeathEvaluator.evaluate(state, at: .now)
        #expect(cause == .careMistakes)
    }

    @Test
    func `dies from too many injuries`() {
        var state = makeTestState()
        state.injuryCount = 20
        let cause = DeathEvaluator.evaluate(state, at: .now)
        #expect(cause == .injuries)
    }

    @Test
    func `dies from untreated injury after 6 hours`() {
        let start = Date.now
        var state = makeTestState()
        state.isInjured = true
        state.timestamps.injuredAt = start

        let later = start.addingTimeInterval(
            TimeConstants.untreatedInjuryDeathTime + 1
        )
        let cause = DeathEvaluator.evaluate(state, at: later)
        #expect(cause == .untreatedInjury)
    }

    @Test
    func `dies exactly at the care-mistake threshold`() {
        var state = makeTestState()
        state.careMistakes = TimeConstants.maxCareMistakesBeforeDeath
        #expect(DeathEvaluator.evaluate(state, at: .now) == .careMistakes)
    }

    @Test
    func `dies exactly at the injury-count threshold`() {
        var state = makeTestState()
        state.injuryCount = TimeConstants.maxInjuriesBeforeDeath
        #expect(DeathEvaluator.evaluate(state, at: .now) == .injuries)
    }

    @Test
    func `survives one short of every threshold`() {
        let start = Date.now
        var state = makeTestState()
        state.careMistakes = TimeConstants.maxCareMistakesBeforeDeath - 1
        state.injuryCount = TimeConstants.maxInjuriesBeforeDeath - 1
        state.isInjured = true
        state.timestamps.injuredAt = start

        // One second before the untreated-injury window elapses.
        let justBefore = start.addingTimeInterval(
            TimeConstants.untreatedInjuryDeathTime - 1
        )
        #expect(DeathEvaluator.evaluate(state, at: justBefore) == nil)
    }

    @Test
    func `dies from a collapse left past the window`() {
        let start = Date.now
        var state = makeTestState(hunger: 0, strength: 0)
        state.timestamps.collapsingAt = start

        let later = start.addingTimeInterval(TimeConstants.collapseDeathTime + 1)
        #expect(DeathEvaluator.evaluate(state, at: later) == .collapse)
    }

    @Test
    func `survives a collapse that has not yet reached the window`() {
        let start = Date.now
        var state = makeTestState(hunger: 0, strength: 0)
        state.timestamps.collapsingAt = start

        let justBefore = start.addingTimeInterval(TimeConstants.collapseDeathTime - 1)
        #expect(DeathEvaluator.evaluate(state, at: justBefore) == nil)
    }

    @Test
    func `survives with acceptable stats`() {
        let state = makeTestState()
        let cause = DeathEvaluator.evaluate(state, at: .now)
        #expect(cause == nil)
    }
}
