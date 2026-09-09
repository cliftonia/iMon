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

    /// The view drawn inside the `LCDBezel` at the top.
    let lcd: LCD

    /// The one-line strip shown between the LCD and the buttons.
    let info: Info

    /// The controls pinned to the bottom of the screen.
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
