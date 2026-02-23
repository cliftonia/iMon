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
    var totalDuration: TimeInterval { Double(frames.count) * frameDuration }

    /// Return a copy with a different frame duration.
    func withFrameDuration(
        _ duration: TimeInterval
    ) -> SpriteAnimation {
        SpriteAnimation(
            frames: frames,
            frameDuration: duration,
            loops: loops
        )
    }

    /// Return a copy with looping toggled.
    func withLoops(_ loops: Bool) -> SpriteAnimation {
        SpriteAnimation(
            frames: frames,
            frameDuration: frameDuration,
            loops: loops
        )
    }

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
