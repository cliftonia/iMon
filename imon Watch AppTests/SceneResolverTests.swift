import Testing
@testable import imon_Watch_App

// The rules, codified:
// - Home, idle/refusing → full environment (real light, day phase, weather).
// - Home, action ceremony → clean lit booth (no weather, no room).
// - Arena (battle/training) → outdoors: lit by day, dark at night, no room/weather.
struct SceneResolverTests {

    // MARK: - Home: full environment when not in an action scene

    @Test func `idle home shows the full environment`() {
        let scene = SceneResolver.home(
            dayPhase: .night, lightsOn: false,
            weather: .rain, isInActionScene: false
        )
        #expect(scene.lightsOn == false)
        #expect(scene.dayPhase == .night)
        #expect(scene.weather == .rain)
    }

    @Test func `inside at night keeps the room and weather when idle`() {
        let scene = SceneResolver.home(
            dayPhase: .inside, lightsOn: true,
            weather: .cloudy, isInActionScene: false
        )
        #expect(scene.dayPhase == .inside)
        #expect(scene.weather == .cloudy)
    }

    // A refusal is not an action scene, so it stays in the full environment.
    @Test func `refusal at night stays outside in the dark`() {
        let scene = SceneResolver.home(
            dayPhase: .night, lightsOn: false,
            weather: .storm, isInActionScene: false
        )
        #expect(scene.lightsOn == false)
        #expect(scene.dayPhase == .night)
        #expect(scene.weather == .storm)
    }

    // MARK: - Home: clean lit booth during an action ceremony

    @Test func `action ceremony is a clean lit booth`() {
        let scene = SceneResolver.home(
            dayPhase: .night, lightsOn: false,
            weather: .rain, isInActionScene: true
        )
        #expect(scene.lightsOn)                 // always lit so the action reads
        #expect(scene.dayPhase == .day)         // never the room
        #expect(scene.weather == nil)           // no weather overlay
    }

    @Test func `action ceremony stays clean even when it was day with weather`() {
        let scene = SceneResolver.home(
            dayPhase: .day, lightsOn: true,
            weather: .snow, isInActionScene: true
        )
        #expect(scene.lightsOn)
        #expect(scene.weather == nil)
    }

    // MARK: - Arena: outdoors, follows day/night, never the room

    @Test func `arena is lit by day`() {
        let scene = SceneResolver.arena(dayPhase: .day)
        #expect(scene.lightsOn)
        #expect(scene.dayPhase == .day)
        #expect(scene.weather == nil)
    }

    @Test func `arena is dark at night`() {
        let scene = SceneResolver.arena(dayPhase: .night)
        #expect(scene.lightsOn == false)
        #expect(scene.dayPhase == .day)   // outdoors, never the room
        #expect(scene.weather == nil)
    }

    // "If night && inside, training/battle is night" — inside still reads dark.
    @Test func `arena is dark when entered from inside at night`() {
        let scene = SceneResolver.arena(dayPhase: .inside)
        #expect(scene.lightsOn == false)
        #expect(scene.dayPhase == .day)
        #expect(scene.weather == nil)
    }
}
