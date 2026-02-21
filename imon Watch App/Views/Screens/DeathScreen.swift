import SwiftUI

struct DeathScreen: View {

    let presenter: DeathPresenter

    var body: some View {
        VStack(spacing: 12) {
            LCDBezel {
                SpriteView(animator: presenter.spriteAnimator, pixelSize: 4)
                    .background(Color("LCDBackground"))
                    .padding(4)
            }

            Text("R.I.P.")
                .font(.system(
                    size: 16,
                    weight: .bold,
                    design: .monospaced
                ))

            Text(presenter.viewModel.speciesName)
                .font(.system(size: 11, design: .monospaced))

            Text("Age: \(presenter.viewModel.ageDays) days")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(Color.gray)

            Button("New Egg") {
                presenter.restartAction()
            }
            .accessibilityLabel("Start new egg")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            "Death screen. Your Digimon has passed away."
        )
    }
}
