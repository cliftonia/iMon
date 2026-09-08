import SwiftUI

/// A labelled row of hearts showing a stat as filled and hollow symbols.
///
/// Draws `maxCount` hearts with the first `filledCount` filled, and flattens
/// the row into one accessibility element reading the label and the count.
struct HeartMeter: View {

    let label: String
    let filledCount: Int
    let maxCount: Int

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .frame(width: 40, alignment: .leading)

            HStack(spacing: 1) {
                ForEach(Array(0..<maxCount), id: \.self) { index in
                    Image(
                        systemName: index < filledCount
                            ? "heart.fill"
                            : "heart"
                    )
                    .font(.system(size: 8))
                    .foregroundStyle(
                        index < filledCount ? Color.red : Color.gray
                    )
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(label): \(filledCount) of \(maxCount) hearts"
        )
    }
}
