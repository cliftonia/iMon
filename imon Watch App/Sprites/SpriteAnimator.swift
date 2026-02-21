import Foundation
import Observation

/// Drives sprite animation playback on the main thread for SwiftUI display.
@MainActor
@Observable
final class SpriteAnimator {

    private(set) var currentFrame: SpriteFrame = .empty
    private(set) var currentFrameIndex: Int = 0

    private var animation: SpriteAnimation?
    private var timer: Timer?

    func play(_ animation: SpriteAnimation) {
        stop()
        self.animation = animation
        currentFrameIndex = 0
        currentFrame = animation.frames.first ?? .empty

        guard animation.frameCount > 1 else { return }

        timer = Timer.scheduledTimer(
            withTimeInterval: animation.frameDuration,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.advanceFrame()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        animation = nil
        currentFrameIndex = 0
    }

    var isPlaying: Bool { animation != nil }

    private func advanceFrame() {
        guard let animation else { return }
        let nextIndex = currentFrameIndex + 1

        if nextIndex >= animation.frameCount {
            if animation.loops {
                currentFrameIndex = 0
            } else {
                stop()
                return
            }
        } else {
            currentFrameIndex = nextIndex
        }

        currentFrame = animation.frames[currentFrameIndex]
    }

}
