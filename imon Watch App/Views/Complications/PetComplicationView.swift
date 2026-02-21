import SwiftUI
import WidgetKit

struct PetComplicationView: View {

    let speciesName: String
    let hungerHearts: Int
    let strengthHearts: Int

    var body: some View {
        HStack(spacing: 4) {
            VStack(alignment: .leading, spacing: 2) {
                Text(speciesName)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .lineLimit(1)

                HStack(spacing: 1) {
                    ForEach(Array(0..<4), id: \.self) { index in
                        Image(
                            systemName: index < hungerHearts
                                ? "heart.fill"
                                : "heart"
                        )
                        .font(.system(size: 6))
                        .foregroundStyle(
                            index < hungerHearts ? Color.red : Color.gray
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(speciesName), hunger \(hungerHearts) of 4"
        )
    }
}
