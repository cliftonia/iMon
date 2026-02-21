import SwiftUI

struct LCDBezel<Content: View>: View {

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color("LCDBackground").opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.6), lineWidth: 1.5)
            )
    }
}
