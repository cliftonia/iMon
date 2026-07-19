import SwiftUI

struct DeathScreen: View {

    let presenter: DeathPresenter

    var body: some View {
        // Scroll-bounded so content can't collide with the clock on 40/41mm.
        ScrollView {
            VStack(spacing: 10) {
                AnimatedSpriteBezel(
                    animator: presenter.spriteAnimator,
                    pixelSize: 3
                )

                Text("R.I.P.")
                    .font(.system(
                        size: 16,
                        weight: .bold,
                        design: .monospaced
                    ))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(presenter.viewModel.speciesName)
                    .font(.system(size: 11, design: .monospaced))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text("Age: \(presenter.viewModel.ageDays) days")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(Color.gray)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Button("New Egg") {
                    presenter.restartAction()
                }
                .accessibilityLabel("Start new egg")
            }
            .padding(.vertical, 4)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            "Death screen. Your Creature has passed away."
        )
    }
}
