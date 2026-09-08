import Foundation

/// Horizontal orientation of a creature.
///
/// Sprites are authored facing `left`; `right` mirrors them — frame data is
/// never pre-mirrored, so each context states its facing via `.facing(_:)`.
/// Differing context facings are deliberate (front and side art face
/// opposite ways): do not "unify" them.
nonisolated enum Facing: Sendable {
    case left
    case right
}

nonisolated extension SpriteFrame {
    /// `.left` is the authored orientation and returns `self` unchanged.
    func facing(_ facing: Facing) -> SpriteFrame {
        facing == .right ? mirrored() : self
    }
}

nonisolated extension SpriteAnimation {
    /// `.left` is the authored orientation and returns `self` unchanged.
    func facing(_ facing: Facing) -> SpriteAnimation {
        facing == .right ? mirrored() : self
    }
}
