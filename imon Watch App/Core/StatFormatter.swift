import Foundation

/// Display formatting for numeric stats — grouped thousands and a win-rate
/// percent. A `nonisolated enum` helper in the style of `WeatherTemperatureFormatter`,
/// reusable by the Stats screen and the complication.
nonisolated enum StatFormatter {

    /// Locale-grouped thousands, e.g. 12_340 -> "12,340".
    static func grouped(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// Win rate as a whole-number percent (0...100), or nil when there are no
    /// battles to divide by. Clamps in `Double` before converting, so extreme
    /// ratios can never trap the `Int` conversion.
    static func percent(_ part: Int, of whole: Int) -> String? {
        guard whole > 0 else { return nil }
        let ratio = Double(part) / Double(whole) * 100
        return "\(Int(min(100, max(0, ratio.rounded()))))%"
    }
}
