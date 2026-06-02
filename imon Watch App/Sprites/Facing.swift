import Foundation

/// Horizontal orientation of a creature.
///
/// **Single source of truth for facing.** Every creature sprite is authored
/// facing `left`; `right` mirrors it. Frame data is NEVER pre-mirrored — each
/// context (wander, feed, train, battle) states its facing explicitly via
/// `.facing(_:)`, so changing one context can't silently flip another.
nonisolated enum Facing: Sendable {
    case left
    case right
}

nonisolated extension SpriteFrame {
    /// Returns the frame oriented to face the given direction.
    func facing(_ facing: Facing) -> SpriteFrame {
        facing == .right ? mirrored() : self
    }
}

nonisolated extension SpriteAnimation {
    /// Returns the animation oriented to face the given direction.
    func facing(_ facing: Facing) -> SpriteAnimation {
        facing == .right ? mirrored() : self
    }
}
