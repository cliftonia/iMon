import Foundation

nonisolated struct Tagged<Phantom, RawValue>: Sendable where RawValue: Sendable {
    let rawValue: RawValue

    init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
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

extension Tagged: CustomStringConvertible {
    var description: String {
        String(describing: rawValue)
    }
}

extension Tagged: ExpressibleByUnicodeScalarLiteral where RawValue == String {
    init(unicodeScalarLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension Tagged: ExpressibleByExtendedGraphemeClusterLiteral where RawValue == String {
    init(extendedGraphemeClusterLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension Tagged: ExpressibleByStringLiteral where RawValue == String {
    init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension Tagged: ExpressibleByIntegerLiteral where RawValue == Int {
    init(integerLiteral value: Int) {
        self.init(rawValue: value)
    }
}
