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

    var battleHP: Int {
        switch self {
        case .fresh: 1
        case .inTraining: 2
        case .rookie: 3
        case .champion: 4
        case .ultimate: 5
        }
    }

    /// Lifetime active steps needed to leave this stage (a single growing
    /// counter). The final stage never evolves, so its bar is effectively
    /// unreachable.
    var stepsToEvolve: Int {
        switch self {
        case .fresh: 10_000
        case .inTraining: 50_000
        case .rookie: 300_000
        case .champion: 1_000_000
        case .ultimate: .max
        }
    }

    /// Extra steps added to this stage's evolution goal for each lazy day (fewer
    /// than `StepProgress.lazyThreshold` active steps). Later stages are penalised
    /// harder, so neglecting an older pet costs more progress.
    var lazyDayPenalty: Int {
        switch self {
        case .fresh: 4_000
        case .inTraining: 6_000
        case .rookie: 8_000
        case .champion: 10_000
        case .ultimate: 0
        }
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
