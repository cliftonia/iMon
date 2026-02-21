import Foundation

nonisolated enum EvolutionStage: Int, Codable, Sendable, CaseIterable, Comparable {
    case fresh = 0
    case inTraining
    case rookie
    case champion
    case ultimate

    nonisolated static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .fresh: "Fresh"
        case .inTraining: "In-Training"
        case .rookie: "Rookie"
        case .champion: "Champion"
        case .ultimate: "Ultimate"
        }
    }
}
