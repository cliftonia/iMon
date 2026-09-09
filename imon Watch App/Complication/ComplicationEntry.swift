import Foundation

/// A glanceable snapshot of the pet for the watch-face complication. Pure data,
/// `Codable`, and free of the engine and sprite stack — the app bakes everything
/// (including the pet's 16×16 pixel rows) into this so the widget process can
/// render without importing the whole engine. The widget target deliberately
/// compiles none of the app's source: it decodes the JSON this type writes into
/// its own `WidgetEntry` mirror, so the serialised keys are the contract.
nonisolated struct ComplicationEntry: Codable, Sendable, Equatable {

    /// When the snapshot was baked.
    let date: Date
    /// The pet's species display name.
    let speciesName: String
    /// The pet's current 16×16 sprite, one `UInt16` per row (MSB = leftmost).
    let spriteRows: [UInt16]
    /// Hunger hearts remaining; read against `hungerMax`.
    let hungerValue: Int
    /// Total hunger hearts, the denominator for `hungerValue`.
    let hungerMax: Int
    /// Whether the pet has an outstanding care call.
    let needsAttention: Bool
    /// Whether the pet is injured.
    let isInjured: Bool
    /// Whether the pet has died.
    let isDead: Bool
    /// Whether the pet is still an egg rather than a hatched species.
    let isEgg: Bool
    /// A one-word mood for the inline complication ("happy", "hungry", …).
    let statusText: String
}
