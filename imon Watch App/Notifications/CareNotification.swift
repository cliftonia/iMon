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
        case exercise
        case fading
    }

    let kind: Kind
    let fireDate: Date
    /// The pet's display name, so reminders read personally ("Dotkin is hungry!").
    let petName: String

    var id: String { kind.rawValue }

    var title: String { petName }

    var body: String {
        switch kind {
        case .hunger: "\(petName) is hungry!"
        case .strength: "\(petName) is weak \u{2014} give it vitamins!"
        case .mess: "\(petName) made a mess!"
        case .injury: "\(petName) is hurt \u{2014} heal it!"
        case .exercise: "\(petName) needs some exercise!"
        case .fading: "\(petName) is fading \u{2014} care for it now!"
        }
    }
}
