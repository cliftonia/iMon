import SwiftUI

/// The evolution ring's palette. A file-scope enum because `LCDBezel` is generic,
/// and Swift disallows stored static properties on generic types.
private enum EvolutionRingPalette {
    /// The daylight ring: the signature LCD green, matching the lit screen.
    static let day = Color("LCDBackground")
    /// The night ring: a pale, faintly cool silver echoing the moon and stars
    /// while staying legible against the dark screen.
    static let night = Color(red: 0.86, green: 0.89, blue: 0.95)
}

struct LCDBezel<Content: View>: View {

    let content: Content
    /// Evolution progress (0...1) drawn as a glow filling the bezel; `nil` hides it.
    let evolutionProgress: Double?
    /// The scene's time of day, so the progress ring can shift to a moonlit
    /// colour once the screen goes dark at night.
    let dayPhase: DayPhase

    init(
        evolutionProgress: Double? = nil,
        dayPhase: DayPhase = .day,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.evolutionProgress = evolutionProgress
        self.dayPhase = dayPhase
    }

    /// Only the lights-off night screen is dark; day and the lit indoor room
    /// both keep the green screen, so the ring stays green there.
    private var ringColor: Color {
        dayPhase == .night ? EvolutionRingPalette.night : EvolutionRingPalette.day
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
                ringColor,
                style: StrokeStyle(lineWidth: 2, lineCap: .round)
            )
            .opacity(evolutionProgress == nil ? 0 : 1)
            .accessibilityHidden(true)
    }
}
