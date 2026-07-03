import SwiftUI
import WatchKit

struct ActionButton: View {

    let label: String
    /// Optional debug action fired on a long press (e.g. cycle weather / evolve).
    var longPressAction: (() -> Void)?
    let action: () -> Void
    @Environment(\.lcdTheme) private var theme

    var body: some View {
        Button {
            WKInterfaceDevice.buttonHaptic()
            action()
        } label: {
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .frame(maxWidth: .infinity)
                .frame(height: 28)
                .foregroundStyle(theme.chromeTint)
        }
        .buttonStyle(.bordered)
        // Only override the fill under battery-saver; classic keeps the default.
        .tint(theme == .nightRed ? theme.chromeTint : nil)
        .accessibilityLabel("\(label) button")
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                guard let longPressAction else { return }
                WKInterfaceDevice.buttonHaptic()
                longPressAction()
            }
        )
    }
}
