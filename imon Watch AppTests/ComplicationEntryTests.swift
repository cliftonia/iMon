import Testing
import Foundation
@testable import imon_Watch_App

@Suite("ComplicationEntry")
struct ComplicationEntryTests {

    private let date = Date(timeIntervalSince1970: 1_700_000_000)

    @Test
    func `a healthy pet reads as happy and calm`() {
        let state = makeTestState(species: .emberkin, hunger: 4, strength: 4)
        let entry = ComplicationEntry(date: date, state: state)
        #expect(entry.species == .emberkin)
        #expect(entry.hungerValue == 4)
        #expect(entry.hungerMax == PetSpecies.emberkin.maxHunger)
        #expect(entry.needsAttention == false)
        #expect(entry.statusText == "happy")
    }

    @Test
    func `an empty-hunger pet needs attention and reads as hungry`() {
        let state = makeTestState(species: .emberkin, hunger: 0)
        let entry = ComplicationEntry(date: date, state: state)
        #expect(entry.needsAttention)
        #expect(entry.statusText == "hungry")
    }

    @Test
    func `an injured pet reads as hurt`() {
        var state = makeTestState(species: .emberkin)
        state.isInjured = true
        let entry = ComplicationEntry(date: date, state: state)
        #expect(entry.isInjured)
        #expect(entry.needsAttention)
        #expect(entry.statusText == "hurt")
    }
}
