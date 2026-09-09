import Foundation

/// A single care reminder derived from the pet's state. The `id` is stable per
/// kind, so rescheduling replaces the pending request rather than stacking
/// duplicates.
nonisolated struct CareNotification: Sendable, Equatable, Identifiable {

    /// The reason the reminder fires. Keys both the message text and the stable
    /// identifier: `id` is the raw value, so one pending request per kind.
    nonisolated enum Kind: String, Sendable {
        case hunger
        case strength
        case mess
        case injury
        case exercise
        case fading
    }

    /// Which care need this reminder is for; chooses the message in `title` and `body`.
    let kind: Kind
    /// When the reminder is due — the fire time of the pending request.
    let fireDate: Date
    /// The pet's species — supplies the personal name and the notification sprite.
    let species: PetSpecies

    var id: String { kind.rawValue }

    private var name: String { species.displayName }

    var title: String { name }

    var body: String {
        switch kind {
        case .hunger: "\(name) is hungry!"
        case .strength: "\(name) is weak \u{2014} give it vitamins!"
        case .mess: "\(name) made a mess!"
        case .injury: "\(name) is hurt \u{2014} heal it!"
        case .exercise: "\(name) needs some exercise!"
        case .fading: "\(name) is fading \u{2014} care for it now!"
        }
    }
}
