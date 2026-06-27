import SwiftUI

struct LCDBezel<Content: View>: View {

    let content: Content
    /// Evolution progress (0...1) drawn as a glow filling the bezel; `nil` hides it.
    let evolutionProgress: Double?

    init(
        evolutionProgress: Double? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.evolutionProgress = evolutionProgress
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
            .overlay(evolutionRing)
    }

    /// The LCD-green progress arc, filling clockwise as the pet nears evolution.
    /// Always present (so it animates smoothly); hidden via opacity when unset.
    private var evolutionRing: some View {
        RoundedRectangle(cornerRadius: 6)
            .trim(from: 0, to: max(0, min(1, evolutionProgress ?? 0)))
            .stroke(
                Color("LCDBackground"),
                style: StrokeStyle(lineWidth: 2, lineCap: .round)
            )
            .opacity(evolutionProgress == nil ? 0 : 1)
            .accessibilityHidden(true)
    }
}
