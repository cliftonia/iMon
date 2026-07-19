import Foundation
import WeatherKit

/// Fetches the current weather for the device's location. Closure-based so the
/// WeatherKit/CoreLocation dependency can be mocked in tests and previews.
nonisolated struct WeatherProvider: Sendable {
    let fetchCurrent: @Sendable () async throws -> WeatherSnapshot
}

nonisolated extension WeatherProvider {

    static func live(location: LocationProvider = .live()) -> WeatherProvider {
        WeatherProvider {
            let coordinate = try await location.currentLocation()
            let weather = try await WeatherService.shared.weather(for: coordinate)
            let current = weather.currentWeather
            return WeatherSnapshot(
                temperature: current.temperature,
                condition: WeatherIconCondition(current.condition),
                isDaylight: current.isDaylight,
                humidity: current.humidity
            )
        }
    }

    static func mock(_ snapshot: WeatherSnapshot) -> WeatherProvider {
        WeatherProvider { snapshot }
    }

    static func mockFailing(
        _ error: WeatherError = .weatherUnavailable
    ) -> WeatherProvider {
        WeatherProvider { throw error }
    }
}

nonisolated extension WeatherIconCondition {

    /// Reduces WeatherKit's many conditions to the LCD's icon set.
    init(_ condition: WeatherCondition) {
        switch condition {
        case .clear, .mostlyClear, .hot:
            self = .clear
        case .cloudy, .mostlyCloudy, .partlyCloudy, .haze, .smoky:
            self = .cloudy
        case .breezy, .windy:
            self = .wind
        case .foggy, .blowingDust:
            self = .fog
        case .rain, .drizzle, .heavyRain, .freezingRain,
             .freezingDrizzle, .sunShowers, .hail, .sleet:
            self = .rain
        case .snow, .flurries, .heavySnow, .blizzard,
             .blowingSnow, .wintryMix, .sunFlurries, .frigid:
            self = .snow
        case .thunderstorms, .isolatedThunderstorms,
             .scatteredThunderstorms, .strongStorms,
             .hurricane, .tropicalStorm:
            self = .storm
        @unknown default:
            self = .cloudy
        }
    }
}
