import SwiftUI

struct OnboardingScreen: View {

    let presenter: OnboardingPresenter

    var body: some View {
        VStack(spacing: 6) {
            content
            // Dots + skip pinned to the bottom.
            footer
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 8)
        .padding(.bottom, 20)
        .ignoresSafeArea(.container, edges: .bottom)
    }

    // MARK: - Content (LCD pinned top + scrolling tip), tappable to advance

    private var content: some View {
        VStack(spacing: 6) {
            // Fixed LCD pinned to the top.
            lcd
                .frame(maxWidth: .infinity)

            // The tip lives in a scroll view that eats the remaining space
            // (pinning the LCD above and footer below) and guarantees the full
            // text is reachable - scrolling rather than truncating on small
            // screens. Tips are kept short so scrolling is rarely needed.
            ScrollView {
                speechBubble
            }
            .frame(maxHeight: .infinity)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: presenter.advanceAction)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(
            "\(presenter.viewModel.currentTip.message). "
                + (presenter.viewModel.isLastStep
                    ? "Tap to start." : "Tap to continue.")
        )
    }

    private var lcd: some View {
        LCDBezel {
            SpriteView(animator: presenter.spriteAnimator, pixelSize: 3)
                .background(Color("LCDBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(4)
        }
    }

    private var speechBubble: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(presenter.viewModel.currentTip.message)
                .font(.system(size: 13, design: .monospaced))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(presenter.viewModel.isLastStep ? "tap to start ›" : "tap ›")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(Color.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(white: 0.13))
        )
    }

    // MARK: - Footer (progress dots + skip), pinned at the bottom

    private var footer: some View {
        HStack(spacing: 6) {
            pageDots
                .frame(maxWidth: .infinity, alignment: .leading)

            #if DEBUG
            Button("SKIP", action: presenter.skipAction)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .buttonStyle(.plain)
                .foregroundStyle(Color.gray)
                .accessibilityLabel("Skip tutorial")
            #endif
        }
    }

    private var pageDots: some View {
        HStack(spacing: 4) {
            ForEach(presenter.viewModel.tips) { tip in
                Circle()
                    .fill(
                        tip.id == presenter.viewModel.index
                            ? Color.accentColor
                            : Color.gray.opacity(0.4)
                    )
                    .frame(width: 5, height: 5)
            }
        }
        .accessibilityHidden(true)
    }
}
