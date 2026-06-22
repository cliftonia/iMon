import Foundation

/// A single glanceable snapshot of the pet for the watch-face complication.
/// Display-ready and free of WidgetKit, so the core stays testable; the widget
/// target conforms it to `TimelineEntry` (it already carries `date`).
nonisolated struct ComplicationEntry: Sendable, Equatable {

    let date: Date
    let species: PetSpecies
    let hungerValue: Int
    let hungerMax: Int
    let needsAttention: Bool
    let isInjured: Bool
    let isDead: Bool
    let isEgg: Bool
    let statusText: String

    init(date: Date, state: PetState) {
        let status = PetStatus(from: state)
        self.date = date
        species = status.species
        hungerValue = status.hungerHearts.value
        hungerMax = status.species.maxHunger
        needsAttention = status.needsAttention
        isInjured = status.isInjured
        isDead = status.isDead
        isEgg = status.isEgg
        statusText = Self.mood(for: status)
    }

    /// A one-word mood for the inline complication.
    private static func mood(for status: PetStatus) -> String {
        if status.isDead { return "gone" }
        if status.isEgg { return "egg" }
        if status.isInjured { return "hurt" }
        if status.hungerHearts.isEmpty { return "hungry" }
        if status.strengthHearts.isEmpty { return "weak" }
        if status.poopCount > 0 { return "messy" }
        if status.isSleeping { return "asleep" }
        return "happy"
    }
}
