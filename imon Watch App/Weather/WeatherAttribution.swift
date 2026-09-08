import Foundation

/// The legal attribution WeatherKit's terms require an app to link to wherever
/// it shows Apple Weather data. Linked from the Settings page's About section.
nonisolated enum WeatherAttribution {
    static let legalPageURL = URL(string: "https://weatherkit.apple.com/legal-attribution.html")
}
