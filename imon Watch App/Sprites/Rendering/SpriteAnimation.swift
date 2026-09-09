import Foundation

/// An ordered sequence of sprite frames with per-frame timing and a loop flag.
///
/// A value type so animations compare and copy cheaply; `SpriteAnimator`
/// advances the frames on a timer.
nonisolated struct SpriteAnimation: Sendable, Hashable {

    /// The frames to play, in order.
    let frames: [SpriteFrame]
    /// How long each frame is shown before advancing to the next.
    let frameDuration: TimeInterval
    /// Whether playback restarts from the first frame after the last.
    let loops: Bool

    /// Creates an animation whose frames play in the given order.
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

    /// A copy with every frame horizontally mirrored; timing and looping
    /// carry over unchanged.
    func mirrored() -> SpriteAnimation {
        SpriteAnimation(
            frames: frames.map { $0.mirrored() },
            frameDuration: frameDuration,
            loops: loops
        )
    }

    /// A single held frame. Non-looping with one frame, so `SpriteAnimator`
    /// displays it without ever scheduling a timer.
    static func still(_ frame: SpriteFrame) -> SpriteAnimation {
        SpriteAnimation(frames: [frame], frameDuration: 1.0, loops: false)
    }
}
