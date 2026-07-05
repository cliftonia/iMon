import Foundation

nonisolated enum Attribute: String, Codable, Sendable {
    case vaccine
    case virus
    case data

    /// Advantage triangle: vaccine > virus > data > vaccine.
    /// The one attribute this attribute beats — keeps the check
    /// exhaustive without a banned `default:`.
    var prey: Attribute {
        switch self {
        case .vaccine: .virus
        case .virus: .data
        case .data: .vaccine
        }
    }

    func hasAdvantageOver(_ other: Attribute) -> Bool {
        prey == other
    }
}
