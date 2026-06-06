import Foundation

/// Weather conditions reduced to the small set the LCD has icons for.
nonisolated enum WeatherIconCondition: Sendable, Equatable, CaseIterable {
    case clear
    case cloudy
    case rain
    case snow
    case storm
    case fog
    case wind

    /// Short human-readable label for the weather header.
    var displayName: String {
        switch self {
        case .clear: "Clear"
        case .cloudy: "Cloudy"
        case .rain: "Rain"
        case .snow: "Snow"
        case .storm: "Storm"
        case .fog: "Fog"
        case .wind: "Windy"
        }
    }
}

/// Immutable current-weather reading. Temperature is kept raw so it can be
/// formatted in the device's locale at display time.
nonisolated struct WeatherSnapshot: Sendable, Equatable {
    let temperature: Measurement<UnitTemperature>
    let condition: WeatherIconCondition
    let isDaylight: Bool
    /// Relative humidity, 0...1.
    let humidity: Double
}

nonisolated enum WeatherError: Error, Sendable {
    case locationUnavailable
    case weatherUnavailable
}

#if DEBUG
nonisolated extension WeatherSnapshot {
    static let sample = WeatherSnapshot(
        temperature: Measurement(value: 18, unit: .celsius),
        condition: .clear,
        isDaylight: true,
        humidity: 0.6
    )
}
#endif
