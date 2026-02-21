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
        state.injuredAt = start

        let later = start.addingTimeInterval(
            TimeConstants.untreatedInjuryDeathTime + 1
        )
        let cause = DeathEvaluator.evaluate(state, at: later)
        #expect(cause == .untreatedInjury)
    }

    @Test
    func `survives with acceptable stats`() {
        let state = makeTestState()
        let cause = DeathEvaluator.evaluate(state, at: .now)
        #expect(cause == nil)
    }
}
