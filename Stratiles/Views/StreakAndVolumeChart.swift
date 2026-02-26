import Charts
import SwiftUI
import StratilesCore

struct StreakAndVolumeChart: View {
    let insights: ActivityInsights

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Miles")
                .font(.headline)

            if insights.currentStreakDays > 0 || insights.longestStreakDays > 0 {
                HStack(spacing: 16) {
                    if insights.currentStreakDays > 0 {
                        Label("\(insights.currentStreakDays)d streak", systemImage: "flame")
                            .foregroundStyle(Theme.stravaOrange)
                    }
                    if insights.longestStreakDays > 0 {
                        Label("\(insights.longestStreakDays)d best", systemImage: "trophy")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.subheadline.weight(.medium))
            }

            if insights.weeklyVolumes.isEmpty {
                Text("Weekly trend will appear after activities are loaded.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Chart(insights.weeklyVolumes, id: \.weekStart) { week in
                    BarMark(
                        x: .value("Week", week.weekStart, unit: .weekOfYear),
                        y: .value("Miles", week.miles)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [Theme.stravaOrange.opacity(0.7), Theme.stravaOrange.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(3)
                }
                .frame(height: 180)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(.quaternary)
                        AxisValueLabel {
                            if let miles = value.as(Double.self) {
                                Text("\(Int(miles))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { value in
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                            .font(.caption2)
                    }
                }

                if let avg = averageMiles {
                    Text("Avg \(avg.formatted(.number.precision(.fractionLength(1)))) mi/week")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(Theme.cardBackground, in: .rect(cornerRadius: 14, style: .continuous))
    }

    private var averageMiles: Double? {
        let nonEmpty = insights.weeklyVolumes.filter { $0.miles > 0 }
        guard !nonEmpty.isEmpty else { return nil }
        return nonEmpty.map(\.miles).reduce(0, +) / Double(nonEmpty.count)
    }
}
