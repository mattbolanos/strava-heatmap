import SwiftUI
import StratilesCore

struct StatsKPIHeader: View {
    let insights: ActivityInsights

    private var movingHoursText: String {
        insights.totalMovingHours.formatted(.number.precision(.fractionLength(1)))
    }

    private var elevationText: String {
        insights.totalElevationGainMeters.formatted(.number.precision(.fractionLength(0)))
    }

    private var peakTimeBucket: Int? {
        guard !insights.trainingRhythm.isEmpty else { return nil }
        var bucketTotals: [Int: Int] = [:]
        for cell in insights.trainingRhythm {
            let bucket = cell.hour / 3
            bucketTotals[bucket, default: 0] += cell.activityCount
        }
        return bucketTotals.max(by: { $0.value < $1.value })?.key
    }

    private var peakTimeLabel: String {
        guard let bucket = peakTimeBucket else { return "" }
        let ranges = ["12-3 AM", "3-6 AM", "6-9 AM", "9 AM-12 PM", "12-3 PM", "3-6 PM", "6-9 PM", "9 PM-12 AM"]
        return ranges[bucket]
    }

    private var peakTimeIcon: String {
        guard let bucket = peakTimeBucket else { return "clock" }
        let icons = ["moon.stars", "sunrise", "sun.and.horizon", "sun.min", "fork.knife", "figure.walk", "sunset", "moon"]
        return icons[bucket]
    }

    private var peakDayIndex: Int? {
        guard !insights.trainingRhythm.isEmpty else { return nil }
        var dayTotals: [Int: Int] = [:]
        for cell in insights.trainingRhythm {
            dayTotals[cell.weekday, default: 0] += cell.activityCount
        }
        return dayTotals.max(by: { $0.value < $1.value })?.key
    }

    private var peakDayLabel: String {
        guard let weekday = peakDayIndex else { return "—" }
        let index = max(1, min(weekday, 7)) - 1
        return Calendar.current.weekdaySymbols[index]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                metricCard(title: "Peak Time", value: peakTimeLabel, icon: peakTimeIcon)
                metricCard(title: "Peak Day", value: peakDayLabel, icon: "calendar")
                metricCard(title: "Activities", value: "\(insights.totalActivities)", icon: "figure.run")
                metricCard(title: "Distance", value: "\(insights.totalMiles.formatted(.number.precision(.fractionLength(1)))) mi", icon: "road.lanes")
            }

            HStack(spacing: 14) {
                Label("\(movingHoursText) h moving", systemImage: "clock")
                Label("\(elevationText) ft gain", systemImage: "mountain.2")
                Label("\(insights.totalKudos) kudos", systemImage: "hand.thumbsup")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if insights.isPartial {
                Text("Limited view from cached daily data while full activity stats refresh.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if !insights.typeBreakdown.isEmpty {
                HStack(spacing: 8) {
                    ForEach(insights.typeBreakdown.prefix(3), id: \.type) { entry in
                        Text("\(entry.type.displayName) \(Int((entry.share * 100).rounded()))%")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.subtleOrange, in: Capsule())
                    }
                    Spacer()
                }
            }
        }
        .padding(14)
        .background(Theme.cardBackground, in: .rect(cornerRadius: 14, style: .continuous))
    }

    private func metricCard(title: String, value: String, subtitle: String? = nil, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .monospacedDigit()
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Theme.subtleOrange, in: .rect(cornerRadius: 12, style: .continuous))
    }
}
