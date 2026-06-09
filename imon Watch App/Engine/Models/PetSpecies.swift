import Foundation

nonisolated enum PetSpecies: String, Codable, Sendable, CaseIterable, Identifiable {
    // rawValues are the original persisted tokens — kept stable so
    // existing saved pets still decode. Never user-visible.
    case dotkin = "dotkin"
    case hopkin = "hopkin"
    case emberkin = "emberkin"
    case marshkin = "marshkin"
    case rexkin = "rexkin"
    case blazekin = "blazekin"
    case dreadkin = "dreadkin"
    case pyrekin = "pyrekin"
    case galekin = "galekin"
    case tidekin = "tidekin"
    case sludgekin = "sludgekin"
    case steelkin = "steelkin"
    case orbkin = "orbkin"
    case plushkin = "plushkin"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dotkin: "Dotkin"
        case .hopkin: "Hopkin"
        case .emberkin: "Emberkin"
        case .marshkin: "Marshkin"
        case .rexkin: "Rexkin"
        case .blazekin: "Blazekin"
        case .dreadkin: "Dreadkin"
        case .pyrekin: "Pyrekin"
        case .galekin: "Galekin"
        case .tidekin: "Tidekin"
        case .sludgekin: "Sludgekin"
        case .steelkin: "Steelkin"
        case .orbkin: "Orbkin"
        case .plushkin: "Plushkin"
        }
    }

    var stage: EvolutionStage {
        switch self {
        case .dotkin: .fresh
        case .hopkin: .inTraining
        case .emberkin, .marshkin: .rookie
        case .rexkin, .blazekin, .dreadkin,
             .pyrekin, .galekin, .tidekin, .sludgekin: .champion
        case .steelkin, .orbkin, .plushkin: .ultimate
        }
    }

    var attribute: Attribute {
        switch self {
        case .dotkin, .hopkin: .data
        case .emberkin: .vaccine
        case .marshkin: .virus
        case .rexkin: .vaccine
        case .blazekin: .data
        case .dreadkin: .virus
        case .pyrekin: .data
        case .galekin: .vaccine
        case .tidekin: .data
        case .sludgekin: .virus
        case .steelkin: .vaccine
        case .orbkin: .data
        case .plushkin: .vaccine
        }
    }

    var basePower: Int {
        switch self {
        case .dotkin: 5
        case .hopkin: 15
        case .emberkin: 40
        case .marshkin: 35
        case .rexkin: 90
        case .blazekin: 75
        case .dreadkin: 85
        case .pyrekin: 70
        case .galekin: 80
        case .tidekin: 78
        case .sludgekin: 30
        case .steelkin: 160
        case .orbkin: 140
        case .plushkin: 130
        }
    }

    var baseWeight: Int {
        switch self {
        case .dotkin, .hopkin: 10
        case .emberkin, .marshkin: 20
        case .rexkin, .blazekin, .dreadkin,
             .pyrekin, .galekin, .tidekin, .sludgekin: 30
        case .steelkin, .orbkin, .plushkin: 40
        }
    }
}
