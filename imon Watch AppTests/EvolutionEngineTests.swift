import Testing
import Foundation
@testable import imon_Watch_App

@Suite("EvolutionEngine")
struct EvolutionEngineTests {

    @Test
    func `botamon evolves to koromon after 1 hour`() {
        let start = Date.now
        var state = makeTestState(
            species: .botamon, at: start
        )
        state.evolvedAt = start

        let later = start.addingTimeInterval(
            TimeConstants.babyEvolutionTime + 1
        )
        let target = EvolutionEngine.checkEvolution(
            for: state, at: later
        )
        #expect(target == .koromon)
    }

    @Test
    func `koromon evolves to agumon with 0-1 care mistakes`() {
        let start = Date.now
        var state = makeTestState(
            species: .koromon, at: start
        )
        state.evolvedAt = start
        state.careMistakes = 0

        let later = start.addingTimeInterval(
            TimeConstants.rookieEvolutionTime + 1
        )
        let target = EvolutionEngine.checkEvolution(
            for: state, at: later
        )
        #expect(target == .agumon)
    }

    @Test
    func `koromon evolves to betamon with 2+ care mistakes`() {
        let start = Date.now
        var state = makeTestState(
            species: .koromon, at: start
        )
        state.evolvedAt = start
        state.careMistakes = 3

        let later = start.addingTimeInterval(
            TimeConstants.rookieEvolutionTime + 1
        )
        let target = EvolutionEngine.checkEvolution(
            for: state, at: later
        )
        #expect(target == .betamon)
    }

    @Test
    func `ultimate stage cannot evolve further`() {
        let state = makeTestState(species: .metalGreymon)
        let target = EvolutionEngine.checkEvolution(
            for: state, at: .now
        )
        #expect(target == nil)
    }
}
