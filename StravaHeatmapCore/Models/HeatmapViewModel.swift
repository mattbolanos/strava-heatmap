import Foundation

public struct HeatmapCell: Hashable, Sendable {
    public let date: Date
    public let miles: Double
    public let activityCount: Int

    public init(date: Date, miles: Double, activityCount: Int) {
        self.date = date
        self.miles = miles
        self.activityCount = activityCount
    }
}

public struct HeatmapWeek: Hashable, Sendable {
    public let start: Date
    public let values: [HeatmapCell]

    public init(start: Date, values: [HeatmapCell]) {
        self.start = start
        self.values = values
    }
}

public struct HeatmapViewModel: Sendable {
    public let weeks: [HeatmapWeek]
    public let maxMiles: Double
    public let totalMiles: Double
    public let today: Date

    public init(weeks: [HeatmapWeek], maxMiles: Double, totalMiles: Double, today: Date) {
        self.weeks = weeks
        self.maxMiles = maxMiles
        self.totalMiles = totalMiles
        self.today = today
    }
}

public struct MonthLabel: Hashable, Sendable {
    public let label: String
    public let weekIndex: Int

    public init(label: String, weekIndex: Int) {
        self.label = label
        self.weekIndex = weekIndex
    }
}
