import Foundation

/// Horizontal orientation of a creature.
///
/// **Single source of truth for facing.** Every creature sprite is authored
/// facing `left`; `right` mirrors it. Frame data is NEVER pre-mirrored — each
/// context (wander, feed, train, battle) states its facing explicitly via
/// `.facing(_:)`, so changing one context can't silently flip another.
///
/// Front frames and side profiles are drawn facing opposite ways, so the
/// context facings deliberately differ: eating shows `.left`, training and
/// battle show `.right`. Do not "unify" them.
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
