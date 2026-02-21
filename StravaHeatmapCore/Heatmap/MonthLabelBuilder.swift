import Foundation

public enum MonthLabelBuilder {
    private static let minWeekGap = 3

    public static func build(from weeks: [HeatmapWeek]) -> [MonthLabel] {
        var labels: [MonthLabel] = []
        var previousMonth = -1
        var previousLabelWeekIndex = Int.min

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM"

        for (weekIndex, week) in weeks.enumerated() {
            let month = Calendar.current.component(.month, from: week.start)
            let isMonthChange = weekIndex == 0 || month != previousMonth
            let enoughGap = weekIndex == 0 || (weekIndex - previousLabelWeekIndex) >= minWeekGap

            if isMonthChange && enoughGap {
                labels.append(MonthLabel(label: formatter.string(from: week.start), weekIndex: weekIndex))
                previousLabelWeekIndex = weekIndex
            }

            previousMonth = month
        }

        return labels
    }
}
