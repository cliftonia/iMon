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

    private static let base = Date(timeIntervalSince1970: 2_000_000)

    /// Every field set to a distinct non-default value, so a field forgotten in
    /// either mapping direction (= a silent save wipe) is caught.
    private func populatedState() -> PetState {
        var state = PetState.hatched(at: Self.base)
        state.species = .galekin
        state.hungerHearts = StatHearts(2)
        state.strengthHearts = StatHearts(1)
        state.weight = Weight(45)
        state.age = 7
        state.poopCount = 3
        state.isSleeping = true
        state.lightsOn = false
        state.isInjured = true
        state.injuryCount = 5
        state.careMistakes = 9
        state.battleWins = 11
        state.battleLosses = 4
        state.trainingCount = 22
        state.lifetimeActiveSteps = 123_456
        state.stepsCreditedToday = 4_321
        state.stepTrackedDay = Self.base.addingTimeInterval(12)
        state.isDead = true
        state.wasNight = true
        state.timestamps.lastFedAt = Self.base.addingTimeInterval(1)
        state.timestamps.lastTrainedAt = Self.base.addingTimeInterval(2)
        state.timestamps.lastPoopAt = Self.base.addingTimeInterval(3)
        state.timestamps.lastHungerDecayAt = Self.base.addingTimeInterval(4)
        state.timestamps.lastStrengthDecayAt = Self.base.addingTimeInterval(5)
        state.timestamps.evolvedAt = Self.base.addingTimeInterval(6)
        state.timestamps.lastAdvancedAt = Self.base.addingTimeInterval(7)
        state.timestamps.injuredAt = Self.base.addingTimeInterval(8)
        state.timestamps.pendingCareMistakeAt = Self.base.addingTimeInterval(9)
        state.timestamps.pendingLightsMistakeAt = Self.base.addingTimeInterval(10)
        state.timestamps.lightsOffAt = Self.base.addingTimeInterval(11)
        return state
    }

    private func roundTrip(_ state: PetState) throws -> PetState {
        let data = try JSONEncoder().encode(PetStateDTO(from: state))
        return PetState(from: try JSONDecoder().decode(PetStateDTO.self, from: data))
    }

    @Test
    func `round-trips every scalar and flag`() throws {
        let state = populatedState()
        let r = try roundTrip(state)
        #expect(r.id == state.id)
        #expect(r.species == state.species)
        #expect(r.hungerHearts == state.hungerHearts)
        #expect(r.strengthHearts == state.strengthHearts)
        #expect(r.weight == state.weight)
        #expect(r.age == state.age)
        #expect(r.poopCount == state.poopCount)
        #expect(r.isSleeping == state.isSleeping)
        #expect(r.lightsOn == state.lightsOn)
        #expect(r.isInjured == state.isInjured)
        #expect(r.injuryCount == state.injuryCount)
        #expect(r.careMistakes == state.careMistakes)
        #expect(r.battleWins == state.battleWins)
        #expect(r.battleLosses == state.battleLosses)
        #expect(r.trainingCount == state.trainingCount)
        #expect(r.isDead == state.isDead)
        #expect(r.isEgg == state.isEgg)
        #expect(r.wasNight == state.wasNight)
        #expect(r.lifetimeActiveSteps == state.lifetimeActiveSteps)
        #expect(r.stepsCreditedToday == state.stepsCreditedToday)
        #expect(r.stepTrackedDay == state.stepTrackedDay)
    }

    @Test
    func `save without fitness fields decodes to zeroed accumulator`() throws {
        let dto = PetStateDTO(from: .hatched(at: Self.base))
        let data = try JSONEncoder().encode(dto)
        var json = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        json.removeValue(forKey: "lifetimeActiveSteps")
        json.removeValue(forKey: "stepsCreditedToday")
        json.removeValue(forKey: "stepTrackedDay")
        let stripped = try JSONSerialization.data(withJSONObject: json)

        let decoded = PetState(from: try JSONDecoder().decode(PetStateDTO.self, from: stripped))

        #expect(decoded.lifetimeActiveSteps == 0)
        #expect(decoded.stepsCreditedToday == 0)
        #expect(decoded.stepTrackedDay == nil)
    }

    @Test
    func `round-trips every timestamp`() throws {
        let state = populatedState()
        let t = try roundTrip(state).timestamps
        let s = state.timestamps
        #expect(t.bornAt == s.bornAt)
        #expect(t.lastFedAt == s.lastFedAt)
        #expect(t.lastTrainedAt == s.lastTrainedAt)
        #expect(t.lastPoopAt == s.lastPoopAt)
        #expect(t.lastHungerDecayAt == s.lastHungerDecayAt)
        #expect(t.lastStrengthDecayAt == s.lastStrengthDecayAt)
        #expect(t.evolvedAt == s.evolvedAt)
        #expect(t.lastAdvancedAt == s.lastAdvancedAt)
        #expect(t.injuredAt == s.injuredAt)
        #expect(t.pendingCareMistakeAt == s.pendingCareMistakeAt)
        #expect(t.pendingLightsMistakeAt == s.pendingLightsMistakeAt)
        #expect(t.lightsOffAt == s.lightsOffAt)
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
