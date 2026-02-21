import SwiftUI
import WatchKit

struct ActionButton: View {

    let label: String
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
    }
}
