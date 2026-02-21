import Foundation

public enum HeatmapBuilder {
    public static let dayLabels: [(key: String, label: String)] = [
        ("sun", ""),
        ("mon", "Mon"),
        ("tue", ""),
        ("wed", "Wed"),
        ("thu", ""),
        ("fri", "Fri"),
        ("sat", ""),
    ]

    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }

    public static func toDateKey(_ date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 1
        let day = components.day ?? 1
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    public static func getLevel(miles: Double, maxMiles: Double) -> Int {
        guard miles > 0, maxMiles > 0 else { return 0 }
        let level = Int(ceil((miles / maxMiles) * 4))
        return min(4, max(1, level))
    }

    public static func buildHeatmapView(heatmap: [HeatmapDay], weeksToShow: Int = 52) -> HeatmapViewModel {
        let today = startOfDay(Date())
        let daysByDate = Dictionary(uniqueKeysWithValues: heatmap.map { ($0.date, $0) })

        let windowStart = addDays(today, -(weeksToShow * 7 - 1))
        let gridStart = startOfWeek(windowStart)
        let gridEnd = endOfWeek(today)

        var weeks: [HeatmapWeek] = []
        var weekStart = gridStart

        while weekStart <= gridEnd {
            let values = (0..<7).map { dayOffset -> HeatmapCell in
                let date = addDays(weekStart, dayOffset)
                let day = daysByDate[toDateKey(date)]
                return HeatmapCell(date: date, miles: day?.miles ?? 0, activityCount: day?.activityCount ?? 0)
            }
            weeks.append(HeatmapWeek(start: weekStart, values: values))
            weekStart = addDays(weekStart, 7)
        }

        let days = weeks.flatMap(\.values)
        let maxMiles = max(0, days.map(\.miles).max() ?? 0)
        let totalMiles = days.reduce(0) { $0 + $1.miles }

        return HeatmapViewModel(weeks: weeks, maxMiles: maxMiles, totalMiles: totalMiles, today: today)
    }

    private static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    private static func addDays(_ date: Date, _ days: Int) -> Date {
        let next = calendar.date(byAdding: .day, value: days, to: date) ?? date
        return startOfDay(next)
    }

    private static func startOfWeek(_ date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        return addDays(date, -(weekday - 1))
    }

    private static func endOfWeek(_ date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        return addDays(date, 7 - weekday)
    }
}
