import Charts
import SwiftUI
import StratilesCore

struct EffortTimelineChart: View {
    let insights: ActivityInsights

    var body: some View {
        if !insights.weeklyEffort.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Weekly Effort")
                        .font(.headline)

                    if let avg = averageWeeklyEffort {
                        Text("Avg \(avg) suffer score/week")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Chart {
                    ForEach(insights.weeklyEffort, id: \.weekStart) { week in
                        AreaMark(
                            x: .value("Week", week.weekStart, unit: .weekOfYear),
                            y: .value("Effort", week.totalSufferScore)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [Theme.stravaOrange.opacity(0.6), Theme.stravaOrange.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Week", week.weekStart, unit: .weekOfYear),
                            y: .value("Effort", week.totalSufferScore)
                        )
                        .foregroundStyle(Theme.stravaOrange)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom)
                    }

                    if let avg = averageWeeklyEffort {
                        RuleMark(y: .value("Average", avg))
                            .foregroundStyle(.secondary.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                    }
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(.quaternary)
                        AxisValueLabel {
                            if let score = value.as(Int.self) {
                                Text("\(score)")
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
            }
            .padding(14)
            .background(Theme.cardBackground, in: .rect(cornerRadius: 14, style: .continuous))
        }
    }

    private var averageWeeklyEffort: Int? {
        let nonEmpty = insights.weeklyEffort.filter { $0.totalSufferScore > 0 }
        guard !nonEmpty.isEmpty else { return nil }
        let total = nonEmpty.map(\.totalSufferScore).reduce(0, +)
        return total / nonEmpty.count
    }
}
