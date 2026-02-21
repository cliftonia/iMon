import Foundation

nonisolated enum DigimonSpecies: String, Codable, Sendable, CaseIterable, Identifiable {
    case botamon
    case koromon
    case agumon
    case betamon
    case greymon
    case tyrannomon
    case devimon
    case meramon
    case airdramon
    case seadramon
    case numemon
    case metalGreymon
    case mamemon
    case monzaemon

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .botamon: "Botamon"
        case .koromon: "Koromon"
        case .agumon: "Agumon"
        case .betamon: "Betamon"
        case .greymon: "Greymon"
        case .tyrannomon: "Tyrannomon"
        case .devimon: "Devimon"
        case .meramon: "Meramon"
        case .airdramon: "Airdramon"
        case .seadramon: "Seadramon"
        case .numemon: "Numemon"
        case .metalGreymon: "MetalGreymon"
        case .mamemon: "Mamemon"
        case .monzaemon: "Monzaemon"
        }
    }

    var stage: EvolutionStage {
        switch self {
        case .botamon: .fresh
        case .koromon: .inTraining
        case .agumon, .betamon: .rookie
        case .greymon, .tyrannomon, .devimon,
             .meramon, .airdramon, .seadramon, .numemon: .champion
        case .metalGreymon, .mamemon, .monzaemon: .ultimate
        }
    }

    var attribute: Attribute {
        switch self {
        case .botamon, .koromon: .data
        case .agumon: .vaccine
        case .betamon: .virus
        case .greymon: .vaccine
        case .tyrannomon: .data
        case .devimon: .virus
        case .meramon: .data
        case .airdramon: .vaccine
        case .seadramon: .data
        case .numemon: .virus
        case .metalGreymon: .vaccine
        case .mamemon: .data
        case .monzaemon: .vaccine
        }
    }

    var basePower: Int {
        switch self {
        case .botamon: 5
        case .koromon: 15
        case .agumon: 40
        case .betamon: 35
        case .greymon: 90
        case .tyrannomon: 75
        case .devimon: 85
        case .meramon: 70
        case .airdramon: 80
        case .seadramon: 78
        case .numemon: 30
        case .metalGreymon: 160
        case .mamemon: 140
        case .monzaemon: 130
        }
    }

    var baseWeight: Int {
        switch self {
        case .botamon, .koromon: 10
        case .agumon, .betamon: 20
        case .greymon, .tyrannomon, .devimon,
             .meramon, .airdramon, .seadramon, .numemon: 30
        case .metalGreymon, .mamemon, .monzaemon: 40
        }
    }

    var bedtimeHour: Int {
        switch self {
        case .botamon, .koromon: 20
        case .devimon, .metalGreymon: 22
        case .numemon: 19
        case .agumon, .betamon, .greymon, .tyrannomon,
             .meramon, .airdramon, .seadramon,
             .mamemon, .monzaemon: 21
        }
    }

    var wakeHour: Int { 7 }
}
