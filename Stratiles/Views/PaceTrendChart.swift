import Charts
import SwiftUI
import StratilesCore

struct PaceTrendChart: View {
    let insights: ActivityInsights

    @State private var selectedType: ActivityType?

    private var availableTypes: [ActivityType] {
        insights.typeBreakdown
            .sorted { $0.activityCount > $1.activityCount }
            .map(\.type)
    }

    private var filteredPoints: [PacePoint] {
        guard let selected = selectedType else { return insights.pacePoints }
        return insights.pacePoints.filter { $0.activityType == selected }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pace Trend")
                    .font(.headline)

                Spacer()

                typeSelector
            }

            if filteredPoints.isEmpty {
                Text(selectedType == nil
                     ? "Pace trend will appear after activities are loaded."
                     : "No pace data for \(selectedType!.displayName).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Chart {
                    ForEach(filteredPoints, id: \.self) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Pace", point.paceSecondsPerMile)
                        )
                        .foregroundStyle(Theme.stravaOrange.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1.5))
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("Pace", point.paceSecondsPerMile)
                        )
                        .foregroundStyle(Theme.stravaOrange.opacity(0.6))
                        .symbolSize(16)
                    }

                    ForEach(rollingAverage, id: \.date) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Avg Pace", point.paceSecondsPerMile),
                            series: .value("Series", "Rolling Avg")
                        )
                        .foregroundStyle(Theme.stravaOrange)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        .interpolationMethod(.catmullRom)
                    }

                    if let avg = averagePace {
                        RuleMark(y: .value("Average", avg))
                            .foregroundStyle(.secondary.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                    }
                }
                .frame(height: 180)
                .chartYScale(domain: .automatic(reversed: true))
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(.quaternary)
                        AxisValueLabel {
                            if let seconds = value.as(Double.self) {
                                Text(formatPace(seconds))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                            .font(.caption2)
                    }
                }

                if let avg = averagePace {
                    Text("Avg \(formatPace(avg))/mi")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(Theme.cardBackground, in: .rect(cornerRadius: 14, style: .continuous))
        .onAppear {
            if selectedType == nil, let first = availableTypes.first {
                selectedType = first
            }
        }
    }

    @ViewBuilder
    private var typeSelector: some View {
        let types = availableTypes
        if types.count <= 4 {
            HStack(spacing: 6) {
                ForEach(types, id: \.self) { type in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedType = type
                        }
                    } label: {
                        Text(type.displayName)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                selectedType == type
                                    ? Theme.stravaOrange.opacity(0.15)
                                    : Color.clear,
                                in: Capsule()
                            )
                            .foregroundStyle(selectedType == type ? Theme.stravaOrange : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        } else {
            Menu {
                ForEach(types, id: \.self) { type in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedType = type
                        }
                    } label: {
                        Label(type.displayName, systemImage: type.category.icon)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selectedType?.displayName ?? "All")
                        .font(.subheadline.weight(.medium))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                }
                .foregroundStyle(Theme.stravaOrange)
            }
        }
    }

    private var averagePace: Double? {
        guard !filteredPoints.isEmpty else { return nil }
        let total = filteredPoints.map(\.paceSecondsPerMile).reduce(0, +)
        return total / Double(filteredPoints.count)
    }

    private var rollingAverage: [PacePoint] {
        let points = filteredPoints
        guard points.count >= 2 else { return [] }

        let windowSeconds: TimeInterval = 28 * 24 * 3600 // 4 weeks
        return points.compactMap { point in
            let windowStart = point.date.addingTimeInterval(-windowSeconds)
            let inWindow = points.filter { $0.date >= windowStart && $0.date <= point.date }
            guard !inWindow.isEmpty else { return nil }
            let avgPace = inWindow.map(\.paceSecondsPerMile).reduce(0, +) / Double(inWindow.count)
            return PacePoint(date: point.date, paceSecondsPerMile: avgPace, activityName: "", miles: 0)
        }
    }

    private func formatPace(_ secondsPerMile: Double) -> String {
        let totalSeconds = Int(secondsPerMile)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}
