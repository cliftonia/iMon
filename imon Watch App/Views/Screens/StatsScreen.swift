import SwiftUI

struct StatsScreen: View {

    let presenter: StatsPresenter

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                speciesHeader
                Divider()
                coreStats
                heartMeters
                Divider()
                battleStats
            }
            .padding(.horizontal, 8)
        }
        .navigationTitle("Stats")
    }

    // MARK: - Sections

    private var speciesHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(presenter.viewModel.speciesName)
                .font(.system(
                    size: 14,
                    weight: .bold,
                    design: .monospaced
                ))

            Text(presenter.viewModel.stageName)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Color.gray)
        }
    }

    private var coreStats: some View {
        VStack(alignment: .leading, spacing: 4) {
            statRow(
                label: "AGE",
                value: "\(presenter.viewModel.ageDays)d"
            )
            statRow(
                label: "WEIGHT",
                value: "\(presenter.viewModel.weightGrams)G"
            )
        }
    }

    private var heartMeters: some View {
        VStack(alignment: .leading, spacing: 4) {
            HeartMeter(
                label: "HUNGER",
                filledCount: presenter.viewModel.hungerHearts
            )
            HeartMeter(
                label: "STR",
                filledCount: presenter.viewModel.strengthHearts
            )
        }
    }

    private var battleStats: some View {
        VStack(alignment: .leading, spacing: 4) {
            statRow(
                label: "HP",
                value: "\(presenter.viewModel.battleHP)"
            )
            statRow(
                label: "WIN",
                value: "\(presenter.viewModel.battleWins)"
            )
            statRow(
                label: "LOSE",
                value: "\(presenter.viewModel.battleLosses)"
            )
            statRow(
                label: "RATE",
                value: presenter.viewModel.winRate
            )
        }
    }

    // MARK: - Helpers

    private func statRow(label: String, value: String) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(
                    size: 10,
                    weight: .medium,
                    design: .monospaced
                ))
                .frame(width: 50, alignment: .leading)

            Text(value)
                .font(.system(size: 10, design: .monospaced))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
    }
}
