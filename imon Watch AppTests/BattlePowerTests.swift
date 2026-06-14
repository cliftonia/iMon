import Testing
import Foundation
@testable import imon_Watch_App

@Suite("BattlePower")
struct BattlePowerTests {

    @Test
    func `power is base plus a strength bonus`() {
        var state = makeTestState(strength: 3)
        state.weight = Weight(20)   // not overweight
        let expected = Double(state.species.basePower) + 3.0 * 5.0
        #expect(BattlePower.calculate(for: state) == expected)
    }

    @Test
    func `more strength means more power`() {
        var weak = makeTestState(strength: 1)
        weak.weight = Weight(20)
        var strong = makeTestState(strength: 4)
        strong.weight = Weight(20)
        #expect(BattlePower.calculate(for: strong) > BattlePower.calculate(for: weak))
    }

    // Overweight halves the effective power.
    @Test
    func `overweight halves power`() {
        var state = makeTestState(strength: 3)
        state.weight = Weight(99)   // overweight
        let raw = Double(state.species.basePower) + 3.0 * 5.0
        #expect(BattlePower.calculate(for: state) == raw * 0.5)
    }
}
