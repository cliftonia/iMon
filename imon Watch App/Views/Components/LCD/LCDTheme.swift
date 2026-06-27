import SwiftUI

/// The LCD colour palette. `classic` is the green Game-Boy-style screen; `nightRed`
/// is the Apple-Watch-Ultra-style red-on-black battery-saver look — easier on the
/// OLED and on dark-adapted eyes. Injected through the environment so a single
/// modifier at the root recolours every `LCDDisplay`.
nonisolated enum LCDTheme: Sendable {
    case classic
    case nightRed

    func backgroundColor(lightsOn: Bool) -> Color {
        switch self {
        case .classic:
            if lightsOn { Color("LCDBackground") } else { Color(white: 0.07) }
        case .nightRed:
            .black
        }
    }

    func pixelColor(lightsOn: Bool) -> Color {
        switch self {
        case .classic:
            if lightsOn { Color("LCDPixelOn") } else { .white }
        case .nightRed:
            if lightsOn {
                Color(red: 1, green: 0.12, blue: 0.08)
            } else {
                Color(red: 0.45, green: 0.05, blue: 0.03)
            }
        }
    }
}

private struct LCDThemeKey: EnvironmentKey {
    static let defaultValue: LCDTheme = .classic
}

extension EnvironmentValues {
    var lcdTheme: LCDTheme {
        get { self[LCDThemeKey.self] }
        set { self[LCDThemeKey.self] = newValue }
    }
}
