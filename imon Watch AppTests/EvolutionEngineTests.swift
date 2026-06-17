import Testing
import Foundation
@testable import imon_Watch_App

@Suite("EvolutionEngine")
struct EvolutionEngineTests {

    @Test
    func `dotkin evolves to hopkin once the step gate is met`() {
        var state = makeTestState(species: .dotkin)
        state.lifetimeActiveSteps = EvolutionStage.fresh.stepsToEvolve
        #expect(EvolutionEngine.checkEvolution(for: state) == .hopkin)
    }

    @Test
    func `dotkin does not evolve below the step gate`() {
        var state = makeTestState(species: .dotkin)
        state.lifetimeActiveSteps = EvolutionStage.fresh.stepsToEvolve - 1
        #expect(EvolutionEngine.checkEvolution(for: state) == nil)
    }

    @Test
    func `hopkin evolves to emberkin with 0-1 care mistakes`() {
        var state = makeTestState(species: .hopkin)
        state.lifetimeActiveSteps = EvolutionStage.inTraining.stepsToEvolve
        state.careMistakes = 0
        #expect(EvolutionEngine.checkEvolution(for: state) == .emberkin)
    }

    @Test
    func `hopkin evolves to marshkin with 2+ care mistakes`() {
        var state = makeTestState(species: .hopkin)
        state.lifetimeActiveSteps = EvolutionStage.inTraining.stepsToEvolve
        state.careMistakes = 3
        #expect(EvolutionEngine.checkEvolution(for: state) == .marshkin)
    }

    @Test
    func `the same care state still picks the branch independent of steps`() {
        var lazyEnough = makeTestState(species: .hopkin)
        lazyEnough.lifetimeActiveSteps = EvolutionStage.inTraining.stepsToEvolve * 4
        lazyEnough.careMistakes = 0
        // Far past the gate, but care (not steps) still decides Emberkin.
        #expect(EvolutionEngine.checkEvolution(for: lazyEnough) == .emberkin)
    }

    @Test
    func `ultimate stage cannot evolve further`() {
        var state = makeTestState(species: .steelkin)
        state.lifetimeActiveSteps = 5_000_000
        #expect(EvolutionEngine.checkEvolution(for: state) == nil)
    }
}
