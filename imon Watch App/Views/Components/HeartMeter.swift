import SwiftUI

struct HeartMeter: View {

    let label: String
    let filledCount: Int
    let maxCount: Int

    init(label: String, filledCount: Int, maxCount: Int = 4) {
        self.label = label
        self.filledCount = filledCount
        self.maxCount = maxCount
    }

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .frame(width: 40, alignment: .leading)

            HStack(spacing: 1) {
                ForEach(0..<maxCount, id: \.self) { index in
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
