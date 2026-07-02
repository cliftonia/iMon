import Testing
import Foundation
@testable import imon_Watch_App

@Suite("CollapseTracker")
struct CollapseTrackerTests {

    @Test
    func `isLanguishing is true only when both stats are empty`() {
        #expect(makeTestState(hunger: 0, strength: 0).isLanguishing)
        #expect(!makeTestState(hunger: 1, strength: 0).isLanguishing)
        #expect(!makeTestState(hunger: 0, strength: 1).isLanguishing)
        #expect(!makeTestState(hunger: 2, strength: 2).isLanguishing)
    }

    @Test
    func `both stats empty starts the collapse countdown`() {
        let now = Date.now
        let state = makeTestState(hunger: 0, strength: 0, at: now)
        let result = CollapseTracker.apply(to: state, at: now)
        #expect(result.timestamps.collapsingAt == now)
    }

    @Test
    func `an existing countdown is not reset while still languishing`() {
        let started = Date.now
        var state = makeTestState(hunger: 0, strength: 0, at: started)
        state.timestamps.collapsingAt = started
        let later = started.addingTimeInterval(600)
        let result = CollapseTracker.apply(to: state, at: later)
        #expect(result.timestamps.collapsingAt == started)
    }

    @Test
    func `recovering either stat clears the countdown`() {
        let now = Date.now
        var withHunger = makeTestState(hunger: 1, strength: 0, at: now)
        withHunger.timestamps.collapsingAt = now
        #expect(CollapseTracker.apply(to: withHunger, at: now).timestamps.collapsingAt == nil)

        var withStrength = makeTestState(hunger: 0, strength: 1, at: now)
        withStrength.timestamps.collapsingAt = now
        #expect(CollapseTracker.apply(to: withStrength, at: now).timestamps.collapsingAt == nil)
    }

    @Test
    func `a dead or egg pet is left untouched`() {
        let now = Date.now
        var dead = makeTestState(hunger: 0, strength: 0, at: now)
        dead.isDead = true
        #expect(CollapseTracker.apply(to: dead, at: now).timestamps.collapsingAt == nil)

        var egg = makeTestState(hunger: 0, strength: 0, at: now)
        egg.isEgg = true
        #expect(CollapseTracker.apply(to: egg, at: now).timestamps.collapsingAt == nil)
    }
}
