import SwiftUI

/// Draws a 16x16 sprite at a small pixel size — either following an
/// animator's current frame or rendering one fixed frame.
struct SpriteView: View {

    private let animator: SpriteAnimator?
    private let staticFrame: SpriteFrame
    private let pixelSize: CGFloat
    private let pixelColor: Color

    init(
        animator: SpriteAnimator,
        pixelSize: CGFloat = 4,
        pixelColor: Color = Color("LCDPixelOn")
    ) {
        self.animator = animator
        self.staticFrame = .empty
        self.pixelSize = pixelSize
        self.pixelColor = pixelColor
    }

    init(
        frame: SpriteFrame,
        pixelSize: CGFloat,
        pixelColor: Color = Color("LCDPixelOn")
    ) {
        self.animator = nil
        self.staticFrame = frame
        self.pixelSize = pixelSize
        self.pixelColor = pixelColor
    }

    var body: some View {
        Canvas { context, _ in
            let frame = animator?.currentFrame ?? staticFrame
            for y in 0..<SpriteFrame.size {
                for x in 0..<SpriteFrame.size where frame.pixel(x: x, y: y) {
                    context.fillCell(
                        x: x, y: y,
                        pixelWidth: pixelSize, pixelHeight: pixelSize,
                        color: pixelColor
                    )
                }
            }
        }
        .frame(
            width: CGFloat(SpriteFrame.size) * pixelSize,
            height: CGFloat(SpriteFrame.size) * pixelSize
        )
        .accessibilityHidden(true)
    }
}
