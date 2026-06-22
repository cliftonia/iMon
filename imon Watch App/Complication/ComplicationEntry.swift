import Foundation

/// A glanceable snapshot of the pet for the watch-face complication. Pure data,
/// `Codable`, and free of the engine and sprite stack — the app bakes everything
/// (including the pet's 16×16 pixel rows) into this so the widget process can
/// render without importing the whole engine. This is the single type shared
/// between the app and the `SkykinComplication` widget target.
nonisolated struct ComplicationEntry: Codable, Sendable, Equatable {

    let date: Date
    let speciesName: String
    /// The pet's current 16×16 sprite, one `UInt16` per row (MSB = leftmost).
    let spriteRows: [UInt16]
    let hungerValue: Int
    let hungerMax: Int
    let needsAttention: Bool
    let isInjured: Bool
    let isDead: Bool
    let isEgg: Bool
    /// A one-word mood for the inline complication ("happy", "hungry", …).
    let statusText: String
}
