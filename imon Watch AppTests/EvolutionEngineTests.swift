import Testing
import Foundation
@testable import imon_Watch_App

@Suite("EvolutionEngine")
struct EvolutionEngineTests {

    @Test
    func `dotkin evolves to hopkin after 1 hour`() {
        let start = Date.now
        var state = makeTestState(
            species: .dotkin, at: start
        )
        state.timestamps.evolvedAt = start

        let later = start.addingTimeInterval(
            TimeConstants.babyEvolutionTime + 1
        )
        let target = EvolutionEngine.checkEvolution(
            for: state, at: later
        )
        #expect(target == .hopkin)
    }

    @Test
    func `hopkin evolves to emberkin with 0-1 care mistakes`() {
        let start = Date.now
        var state = makeTestState(
            species: .hopkin, at: start
        )
        state.timestamps.evolvedAt = start
        state.careMistakes = 0

        let later = start.addingTimeInterval(
            TimeConstants.rookieEvolutionTime + 1
        )
        let target = EvolutionEngine.checkEvolution(
            for: state, at: later
        )
        #expect(target == .emberkin)
    }

    @Test
    func `hopkin evolves to marshkin with 2+ care mistakes`() {
        let start = Date.now
        var state = makeTestState(
            species: .hopkin, at: start
        )
        state.timestamps.evolvedAt = start
        state.careMistakes = 3

        let later = start.addingTimeInterval(
            TimeConstants.rookieEvolutionTime + 1
        )
        let target = EvolutionEngine.checkEvolution(
            for: state, at: later
        )
        #expect(target == .marshkin)
    }

    @Test
    func `ultimate stage cannot evolve further`() {
        let state = makeTestState(species: .steelkin)
        let target = EvolutionEngine.checkEvolution(
            for: state, at: .now
        )
        #expect(target == nil)
    }
}
