import SwiftUI

struct SpriteView: View {

    let animator: SpriteAnimator
    let pixelSize: CGFloat

    init(animator: SpriteAnimator, pixelSize: CGFloat = 4) {
        self.animator = animator
        self.pixelSize = pixelSize
    }

    var body: some View {
        Canvas { context, _ in
            let frame = animator.currentFrame
            let pixelColor: Color = Color("LCDPixelOn")

            for y in 0..<SpriteFrame.size {
                for x in 0..<SpriteFrame.size {
                    guard frame.pixel(x: x, y: y) else { continue }
                    let rect = CGRect(
                        x: CGFloat(x) * pixelSize,
                        y: CGFloat(y) * pixelSize,
                        width: pixelSize + 0.5,
                        height: pixelSize + 0.5
                    )
                    context.fill(Path(rect), with: .color(pixelColor))
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
