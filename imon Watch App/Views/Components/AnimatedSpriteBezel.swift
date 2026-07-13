import SwiftUI

/// A bezel-framed animator sprite on the LCD background — the shared
/// assembly used by the death, hatch, and onboarding screens.
struct AnimatedSpriteBezel: View {

    let animator: SpriteAnimator
    let pixelSize: CGFloat

    var body: some View {
        LCDBezel {
            SpriteView(animator: animator, pixelSize: pixelSize)
                .background(Color("LCDBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(4)
        }
    }
}
