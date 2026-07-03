import SwiftUI

struct MenuIconRow: View {

    let selectedIndex: Int
    @Environment(\.lcdTheme) private var theme

    private let icons: [(String, String)] = [
        ("heart.text.square", "Status"),
        ("fork.knife", "Feed"),
        ("figure.run", "Train"),
        ("burst", "Battle"),
        ("shower", "Clean"),
        ("lightbulb", "Lights"),
        ("cross.case", "Medical"),
        ("gearshape", "Settings")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(
                Array(icons.enumerated()),
                id: \.offset
            ) { index, icon in
                Image(systemName: icon.0)
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity)
                    .frame(height: 22)
                    .foregroundStyle(
                        index == selectedIndex
                            ? theme.chromeTint
                            : theme.chromeMutedTint
                    )
                    .background(
                        index == selectedIndex
                            ? RoundedRectangle(cornerRadius: 2)
                                .fill(theme.chromeTint.opacity(0.2))
                            : nil
                    )
                    .accessibilityLabel(icon.1)
            }
        }
    }
}
