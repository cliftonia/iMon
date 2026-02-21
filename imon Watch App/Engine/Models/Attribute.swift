import Foundation

nonisolated enum Attribute: String, Codable, Sendable {
    case vaccine
    case virus
    case data

    /// Advantage triangle: vaccine > virus > data > vaccine
    func hasAdvantageOver(_ other: Attribute) -> Bool {
        switch (self, other) {
        case (.vaccine, .virus), (.virus, .data), (.data, .vaccine):
            true
        default:
            false
        }
    }
}
