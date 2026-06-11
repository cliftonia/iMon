import Foundation

/// The resolved look of the LCD for a given moment — the single source of truth
/// for which scene shows, so the rules live in one testable place instead of
/// scattered across the views.
nonisolated struct LCDScene: Equatable, Sendable {
    let lightsOn: Bool
    let dayPhase: DayPhase
    let weather: WeatherIconCondition?
}

nonisolated enum SceneResolver {

    /// The home (pet) screen.
    ///
    /// - During an **action ceremony** (feeding, cleaning, healing) the screen
    ///   becomes a clean, lit booth — no weather, no room — so the action reads
    ///   clearly. A **refusal** is *not* an action scene, so it stays in the
    ///   full environment.
    /// - Otherwise it's the full environment: real light, day phase and weather.
    static func home(
        dayPhase: DayPhase,
        lightsOn: Bool,
        weather: WeatherIconCondition?,
        isInActionScene: Bool
    ) -> LCDScene {
        if isInActionScene {
            return LCDScene(lightsOn: true, dayPhase: .day, weather: nil)
        }
        return LCDScene(lightsOn: lightsOn, dayPhase: dayPhase, weather: weather)
    }

    /// The battle / training arena — always outdoors: lit by day, dark at night,
    /// never the inside room, never weather.
    static func arena(dayPhase: DayPhase) -> LCDScene {
        LCDScene(lightsOn: dayPhase == .day, dayPhase: .day, weather: nil)
    }
}
