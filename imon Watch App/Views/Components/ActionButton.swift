import SwiftUI
import WatchKit

struct ActionButton: View {

    let label: String
    /// Optional debug action fired on a long press (e.g. cycle weather / evolve).
    var longPressAction: (() -> Void)?
    let action: () -> Void

    var body: some View {
        Button {
            WKInterfaceDevice.buttonHaptic()
            action()
        } label: {
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .frame(maxWidth: .infinity)
                .frame(height: 28)
        }
        .buttonStyle(.bordered)
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
