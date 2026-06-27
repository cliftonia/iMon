import Testing
@testable import imon_Watch_App

@Suite("EvolutionChart reachability")
struct EvolutionChartTests {

    /// Every species must be reachable from the starting Dotkin by walking the
    /// chart edges (care mistakes reset on each evolution, so per-stage gates are
    /// independently satisfiable). A fixed-point graph traversal proves it.
    @Test
    func `every species is reachable from the starting egg`() {
        var reachable: Set<PetSpecies> = [.dotkin]
        var changed = true
        while changed {
            changed = false
            for requirement in EvolutionChart.requirements
            where reachable.contains(requirement.from) && !reachable.contains(requirement.to) {
                reachable.insert(requirement.to)
                changed = true
            }
        }

        let unreachable = Set(PetSpecies.allCases).subtracting(reachable)
        #expect(unreachable.isEmpty, "Unreachable species: \(unreachable)")
    }

    /// Every non-final species must offer at least one outgoing evolution, so no
    /// pre-ultimate pet is a dead end.
    @Test
    func `every pre-ultimate species has an outgoing path`() {
        for species in PetSpecies.allCases where species.stage != .ultimate {
            let hasPath = EvolutionChart.requirements.contains { $0.from == species }
            #expect(hasPath, "\(species) has no evolution")
        }
    }
}
