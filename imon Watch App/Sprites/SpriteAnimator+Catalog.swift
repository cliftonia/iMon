import Foundation

// MARK: - Catalog Convenience

extension SpriteAnimator {
    /// Play the catalog animation for a species and kind.
    ///
    /// Shared by every presenter so call sites read
    /// `animator.play(.idle, for: species)` instead of repeating
    /// `animator.play(SpriteCatalog.animation(for: species, kind: .idle))`.
    func play(_ kind: SpriteCatalog.AnimationKind, for species: PetSpecies) {
        play(SpriteCatalog.animation(for: species, kind: kind))
    }
}
