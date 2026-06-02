import SwiftUI

struct GameModeLayout<
    LCD: View,
    Info: View,
    Buttons: View
>: View {

    let lcd: LCD
    let info: Info
    let buttons: Buttons

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
