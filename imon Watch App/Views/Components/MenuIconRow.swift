import SwiftUI

struct MenuIconRow: View {

    let selectedIndex: Int

    private let icons: [(String, String)] = [
        ("heart.text.square", "Status"),
        ("fork.knife", "Feed"),
        ("figure.run", "Train"),
        ("burst", "Battle"),
        ("shower", "Clean"),
        ("lightbulb", "Lights"),
        ("cross.case", "Medical"),
        ("exclamationmark.triangle", "Call")
    ]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(
                Array(icons.enumerated()),
                id: \.offset
            ) { index, icon in
                Image(systemName: icon.0)
                    .font(.system(size: 10))
                    .frame(width: 16, height: 16)
                    .foregroundStyle(
                        index == selectedIndex
                            ? Color.white
                            : Color.gray
                    )
                    .background(
                        index == selectedIndex
                            ? RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.2))
                            : nil
                    )
                    .accessibilityLabel(icon.1)
            }
        }
    }
}
