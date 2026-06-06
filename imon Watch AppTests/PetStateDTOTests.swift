import Foundation
import Testing
@testable import imon_Watch_App

@Suite("PetStateDTO")
struct PetStateDTOTests {

    @Test
    func `round-trips through JSON preserving fields and timestamps`() throws {
        let date = Date(timeIntervalSince1970: 1_000_000)
        var state = PetState.hatched(at: date)
        state.species = .emberkin
        state.battleWins = 3
        state.poopCount = 2
        state.timestamps.injuredAt = date.addingTimeInterval(60)
        state.timestamps.lastAdvancedAt = date.addingTimeInterval(120)

        let data = try JSONEncoder().encode(PetStateDTO(from: state))
        let dto = try JSONDecoder().decode(PetStateDTO.self, from: data)
        let decoded = PetState(from: dto)

        #expect(decoded.id == state.id)
        #expect(decoded.species == state.species)
        #expect(decoded.battleWins == state.battleWins)
        #expect(decoded.poopCount == state.poopCount)
        #expect(decoded.isEgg == state.isEgg)
        #expect(decoded.timestamps.bornAt == state.timestamps.bornAt)
        #expect(decoded.timestamps.injuredAt == state.timestamps.injuredAt)
        #expect(decoded.timestamps.lastAdvancedAt == state.timestamps.lastAdvancedAt)
        #expect(dto.schemaVersion == PetStateDTO.currentVersion)
    }

    @Test
    func `legacy save without a schema version still decodes`() throws {
        var dto = PetStateDTO(from: .hatched(at: Date(timeIntervalSince1970: 0)))
        dto.schemaVersion = nil
        let data = try JSONEncoder().encode(dto)

        let decoded = try JSONDecoder().decode(PetStateDTO.self, from: data)

        #expect(decoded.schemaVersion == nil)
    }
}
