import SwiftUI
import StratilesCore

struct TrainingRhythmHeatmap: View {
    let insights: ActivityInsights

    @Environment(\.colorScheme) private var colorScheme

    private let weekdays = Array(1...7)
    private let bucketCount = 8
    private let tileGap: CGFloat = 3
    private let labelWidth: CGFloat = 16

    private let hourLabels = ["12a", "3a", "6a", "9a", "12p", "3p", "6p", "9p"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("When You Train")
                .font(.headline)

            if insights.trainingRhythm.isEmpty {
                Text("Rhythm view unlocks after a full activity refresh.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                rhythmGrid
                legend
            }
        }
        .padding(14)
        .background(Theme.cardBackground, in: .rect(cornerRadius: 14, style: .continuous))
    }

    private var rhythmGrid: some View {
        let buckets = buildBuckets()
        let maxCount = buckets.values.max() ?? 0

        return VStack(alignment: .leading, spacing: tileGap) {
            // Hour labels row
            HStack(spacing: tileGap) {
                Text("")
                    .frame(width: labelWidth)

                ForEach(0..<bucketCount, id: \.self) { bucket in
                    Text(hourLabels[bucket])
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day rows
            ForEach(weekdays, id: \.self) { weekday in
                HStack(spacing: tileGap) {
                    Text(dayLabel(weekday))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: labelWidth, alignment: .leading)

                    ForEach(0..<bucketCount, id: \.self) { bucket in
                        let count = buckets[BucketKey(weekday: weekday, bucket: bucket)] ?? 0
                        RoundedRectangle(cornerRadius: 3)
                            .fill(tileColor(count: count, maxCount: maxCount))
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }

    private var legend: some View {
        HStack(spacing: 8) {
            Text("Low")
                .font(.caption2)
                .foregroundStyle(.secondary)

            LinearGradient(
                colors: [Theme.subtleOrange, Theme.stravaOrange.opacity(0.9)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 90, height: 8)
            .clipShape(.rect(cornerRadius: 4))

            Text("High")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func buildBuckets() -> [BucketKey: Int] {
        var result: [BucketKey: Int] = [:]
        for cell in insights.trainingRhythm {
            let bucket = cell.hour / 3
            let key = BucketKey(weekday: cell.weekday, bucket: bucket)
            result[key, default: 0] += cell.activityCount
        }
        return result
    }

    private func tileColor(count: Int, maxCount: Int) -> Color {
        guard count > 0, maxCount > 0 else {
            return HeatmapColors.tileColor(level: 0, colorScheme: colorScheme)
        }
        let ratio = Double(count) / Double(maxCount)
        let level: Int
        switch ratio {
        case ..<0.25: level = 1
        case ..<0.50: level = 2
        case ..<0.75: level = 3
        default:      level = 4
        }
        return HeatmapColors.tileColor(level: level, colorScheme: colorScheme)
    }

    private func dayLabel(_ weekday: Int) -> String {
        let index = max(1, min(weekday, 7)) - 1
        return String(Calendar.current.shortWeekdaySymbols[index].prefix(1))
    }
}

private struct BucketKey: Hashable {
    let weekday: Int
    let bucket: Int
}
