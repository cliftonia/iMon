import SwiftUI

/// The game-mode screen shell: the LCD content in an `LCDBezel` on top, a
/// one-line info strip, and buttons pinned to the bottom.
/// Generic over the three slots so callers supply the views while this type
/// owns their vertical arrangement and spacing.
struct GameModeLayout<
    LCD: View,
    Info: View,
    Buttons: View
>: View {

    let lcd: LCD
    let info: Info
    let buttons: Buttons

    /// Creates the layout, evaluating each view builder immediately and
    /// storing the built views.
    init(
        @ViewBuilder lcd: () -> LCD,
        @ViewBuilder info: () -> Info,
        @ViewBuilder buttons: () -> Buttons
    ) {
        self.lcd = lcd()
        self.info = info()
        self.buttons = buttons()
    }

    var body: some View {
        VStack(spacing: 4) {
            LCDBezel { lcd }
                .fixedSize(horizontal: false, vertical: true)

            info
                .frame(height: 20)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            buttons
                .padding(.horizontal, 4)
                .fixedSize(horizontal: false, vertical: true)
                .frame(
                    maxHeight: .infinity,
                    alignment: .bottom
                )
        }
    }
}
