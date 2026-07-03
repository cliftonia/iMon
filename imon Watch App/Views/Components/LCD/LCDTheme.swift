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

    /// The primary chrome tint outside the LCD - selected menu icons, button
    /// labels, the weather line. Battery-saver keeps all of it on the one red.
    var chromeTint: Color {
        switch self {
        case .classic: .white
        case .nightRed: Color(red: 1, green: 0.12, blue: 0.08)
        }
    }

    /// The muted chrome tint - unselected icons and secondary text. A dimmer red
    /// under battery-saver so nothing on screen falls back to grey or white.
    var chromeMutedTint: Color {
        switch self {
        case .classic: .gray
        case .nightRed: Color(red: 0.55, green: 0.10, blue: 0.07)
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
