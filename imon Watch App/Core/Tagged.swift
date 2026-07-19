import Foundation

/// A raw value branded with a phantom type, so identifiers that share a
/// representation (two `String` IDs, say) cannot be mixed at compile time.
/// `Codable` passes the bare raw value through, so the brand never appears
/// in persisted JSON.
nonisolated struct Tagged<Phantom, RawValue>: Sendable where RawValue: Sendable {
    let rawValue: RawValue
}

extension Tagged: Equatable where RawValue: Equatable {}
extension Tagged: Hashable where RawValue: Hashable {}

extension Tagged: Codable where RawValue: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(RawValue.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
