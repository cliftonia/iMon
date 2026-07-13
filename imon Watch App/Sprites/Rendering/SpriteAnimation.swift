import Foundation

/// A sequence of SpriteFrames played at a fixed interval, optionally looping.
nonisolated struct SpriteAnimation: Sendable, Hashable {

    let frames: [SpriteFrame]
    let frameDuration: TimeInterval
    let loops: Bool

    init(
        frames: [SpriteFrame],
        frameDuration: TimeInterval = 0.5,
        loops: Bool = true
    ) {
        self.frames = frames
        self.frameDuration = frameDuration
        self.loops = loops
    }

    var frameCount: Int { frames.count }

    /// Return a copy with every frame horizontally mirrored.
    func mirrored() -> SpriteAnimation {
        SpriteAnimation(
            frames: frames.map { $0.mirrored() },
            frameDuration: frameDuration,
            loops: loops
        )
    }

    /// Single-frame "animation" (static sprite).
    static func still(_ frame: SpriteFrame) -> SpriteAnimation {
        SpriteAnimation(frames: [frame], frameDuration: 1.0, loops: false)
    }
}
