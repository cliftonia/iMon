import SwiftUI

struct HatchScreen: View {

    let presenter: HatchPresenter

    var body: some View {
        VStack(spacing: 12) {
            LCDBezel {
                SpriteView(animator: presenter.spriteAnimator, pixelSize: 4)
                    .background(Color("LCDBackground"))
                    .padding(4)
            }

            phaseLabel
        }
        .task {
            presenter.startHatching()
        }
        .accessibilityLabel("Egg hatching screen")
    }

    // MARK: - Phase Label

    private var phaseLabel: some View {
        Group {
            switch presenter.viewModel.phase {
            case .egg:
                Text("An egg!")
                    .font(.system(size: 12, design: .monospaced))
            case .cracking:
                Text("It's hatching...")
                    .font(.system(size: 12, design: .monospaced))
            case .hatched:
                Text("Botamon is born!")
                    .font(.system(
                        size: 12,
                        weight: .bold,
                        design: .monospaced
                    ))
            }
        }
    }
}
