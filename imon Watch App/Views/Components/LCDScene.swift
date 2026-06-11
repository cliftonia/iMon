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
    /// The scene always **matches where the pet is** — same light and day phase,
    /// so outside stays outside, inside stays the room, and daytime stays lit.
    /// During an **action ceremony** (feeding, cleaning, healing) only the
    /// weather overlay is dropped so the animation reads cleanly; a **refusal**
    /// is not an action scene, so it keeps the weather too.
    static func home(
        dayPhase: DayPhase,
        lightsOn: Bool,
        weather: WeatherIconCondition?,
        isInActionScene: Bool
    ) -> LCDScene {
        LCDScene(
            lightsOn: lightsOn,
            dayPhase: dayPhase,
            weather: isInActionScene ? nil : weather
        )
    }

    /// The battle / training arena — always outdoors: lit by day, dark at night,
    /// never the inside room, never weather.
    static func arena(dayPhase: DayPhase) -> LCDScene {
        LCDScene(lightsOn: dayPhase == .day, dayPhase: .day, weather: nil)
    }
}
