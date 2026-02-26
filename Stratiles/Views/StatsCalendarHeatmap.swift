import SwiftUI
import StratilesCore

struct StatsCalendarHeatmap: View {
    let insights: ActivityInsights

    @Environment(\.colorScheme) private var colorScheme

    private let tileSize: CGFloat = 10
    private let tileGap: CGFloat = 3
    private let labelColumnWidth: CGFloat = 22

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Miles Per Day")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    monthLabelsRow

                    HStack(alignment: .top, spacing: tileGap) {
                        dayLabelsColumn

                        HStack(alignment: .top, spacing: tileGap) {
                            ForEach(Array(insights.heatmapView.weeks.enumerated()), id: \.offset) { _, week in
                                VStack(spacing: tileGap) {
                                    ForEach(week.values, id: \.date) { cell in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(color(for: cell))
                                            .frame(width: tileSize, height: tileSize)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Text("\(insights.totalMiles.formatted(.number.precision(.fractionLength(1)))) mi in \(insights.totalActivities) activities")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Theme.cardBackground, in: .rect(cornerRadius: 14, style: .continuous))
    }

    private var monthLabelsRow: some View {
        let labels = MonthLabelBuilder.build(from: insights.heatmapView.weeks)

        return ZStack(alignment: .leading) {
            ForEach(labels, id: \.self) { label in
                Text(label.label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .offset(x: CGFloat(label.weekIndex) * (tileSize + tileGap))
            }
        }
        .frame(width: gridWidth, height: 12, alignment: .leading)
        .padding(.leading, labelColumnWidth + 8)
    }

    private var dayLabelsColumn: some View {
        VStack(alignment: .leading, spacing: tileGap) {
            ForEach(HeatmapBuilder.dayLabels.indices, id: \.self) { index in
                let fullLabel = HeatmapBuilder.dayLabels[index].label
                Text(fullLabel.isEmpty ? "" : String(fullLabel.prefix(1)))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(width: labelColumnWidth, height: tileSize, alignment: .leading)
            }
        }
    }

    private var gridWidth: CGFloat {
        CGFloat(insights.heatmapView.weeks.count) * (tileSize + tileGap)
    }

    private func color(for cell: HeatmapCell) -> Color {
        guard cell.date <= insights.windowEnd else {
            return HeatmapColors.tileColor(level: 0, colorScheme: colorScheme)
        }

        let level = HeatmapBuilder.getLevel(miles: cell.miles, maxMiles: insights.heatmapView.maxMiles)
        return HeatmapColors.tileColor(level: level, colorScheme: colorScheme)
    }
}
