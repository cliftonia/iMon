import Testing
import Foundation
@testable import imon_Watch_App

@Suite("PetStatus")
struct PetStatusTests {

    @Test
    func `a well-kept pet needs no attention`() {
        let status = PetStatus(from: makeTestState(hunger: 4, strength: 4))
        #expect(status.needsAttention == false)
    }

    @Test
    func `empty hunger needs attention`() {
        let status = PetStatus(from: makeTestState(hunger: 0, strength: 4))
        #expect(status.needsAttention)
    }

    @Test
    func `empty strength needs attention`() {
        let status = PetStatus(from: makeTestState(hunger: 4, strength: 0))
        #expect(status.needsAttention)
    }

    @Test
    func `poop on screen needs attention`() {
        var state = makeTestState(hunger: 4, strength: 4)
        state.poopCount = 1
        #expect(PetStatus(from: state).needsAttention)
    }

    @Test
    func `injury needs attention`() {
        var state = makeTestState(hunger: 4, strength: 4)
        state.isInjured = true
        #expect(PetStatus(from: state).needsAttention)
    }
}
