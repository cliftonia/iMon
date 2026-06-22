import Foundation

/// A single care reminder derived from the pet's state. The `id` is stable per
/// kind, so rescheduling replaces the pending request rather than stacking
/// duplicates.
nonisolated struct CareNotification: Sendable, Equatable, Identifiable {

    nonisolated enum Kind: String, Sendable, CaseIterable {
        case hunger
        case strength
        case mess
        case injury
        case walk
    }

    let kind: Kind
    let fireDate: Date

    var id: String { kind.rawValue }

    var title: String { "Skykin" }

    var body: String {
        switch kind {
        case .hunger: "Your Skykin is hungry!"
        case .strength: "Your Skykin is weak \u{2014} give it vitamins!"
        case .mess: "Your Skykin made a mess!"
        case .injury: "Your Skykin is hurt \u{2014} heal it!"
        case .walk: "Your Skykin wants a walk!"
        }
    }
}
