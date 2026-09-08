import Foundation

// MARK: - Catalog Convenience

extension SpriteAnimator {
    /// Plays a catalog animation; shared by every presenter so the
    /// `SpriteCatalog.animation(for:kind:)` lookup lives in one place.
    func play(_ kind: SpriteCatalog.AnimationKind, for species: PetSpecies) {
        play(SpriteCatalog.animation(for: species, kind: kind))
    }
}
