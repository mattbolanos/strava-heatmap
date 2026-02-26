import Foundation

public struct ActivityTypeBreakdown: Hashable, Sendable {
    public let type: ActivityType
    public let activityCount: Int
    public let share: Double

    public init(type: ActivityType, activityCount: Int, share: Double) {
        self.type = type
        self.activityCount = activityCount
        self.share = share
    }
}

public struct TrainingRhythmCell: Hashable, Sendable {
    public let weekday: Int
    public let hour: Int
    public let activityCount: Int
    public let movingSeconds: Int

    public init(weekday: Int, hour: Int, activityCount: Int, movingSeconds: Int) {
        self.weekday = weekday
        self.hour = hour
        self.activityCount = activityCount
        self.movingSeconds = movingSeconds
    }
}

public struct WeeklyVolume: Hashable, Sendable {
    public let weekStart: Date
    public let miles: Double
    public let activeDays: Int
    public let activityCount: Int

    public init(weekStart: Date, miles: Double, activeDays: Int, activityCount: Int) {
        self.weekStart = weekStart
        self.miles = miles
        self.activeDays = activeDays
        self.activityCount = activityCount
    }
}

public struct PeakDay: Hashable, Sendable, Identifiable {
    public let date: Date
    public let dateKey: String
    public let miles: Double
    public let activityCount: Int
    public let elevationGainMeters: Double
    public let kudosCount: Int

    public var id: String { dateKey }

    public init(
        date: Date,
        dateKey: String,
        miles: Double,
        activityCount: Int,
        elevationGainMeters: Double,
        kudosCount: Int
    ) {
        self.date = date
        self.dateKey = dateKey
        self.miles = miles
        self.activityCount = activityCount
        self.elevationGainMeters = elevationGainMeters
        self.kudosCount = kudosCount
    }
}

public struct PeakActivity: Hashable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let date: Date
    public let miles: Double
    public let elevationGainMeters: Double
    public let kudosCount: Int
    public let movingTimeSeconds: Int
    public let activityType: ActivityType?

    public init(
        id: Int,
        name: String,
        date: Date,
        miles: Double,
        elevationGainMeters: Double,
        kudosCount: Int,
        movingTimeSeconds: Int,
        activityType: ActivityType?
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.miles = miles
        self.elevationGainMeters = elevationGainMeters
        self.kudosCount = kudosCount
        self.movingTimeSeconds = movingTimeSeconds
        self.activityType = activityType
    }
}

public struct ActivityInsights: Sendable {
    public let windowStart: Date
    public let windowEnd: Date
    public let isPartial: Bool

    public let heatmapDays: [HeatmapDay]
    public let heatmapView: HeatmapViewModel

    public let totalActivities: Int
    public let totalMiles: Double
    public let totalMovingHours: Double
    public let totalElevationGainMeters: Double
    public let totalKudos: Int

    public let currentStreakDays: Int
    public let longestStreakDays: Int

    public let weeklyVolumes: [WeeklyVolume]
    public let trainingRhythm: [TrainingRhythmCell]
    public let maxRhythmCount: Int
    public let typeBreakdown: [ActivityTypeBreakdown]
    public let peakDays: [PeakDay]
    public let peakActivities: [PeakActivity]

    public init(
        windowStart: Date,
        windowEnd: Date,
        isPartial: Bool,
        heatmapDays: [HeatmapDay],
        heatmapView: HeatmapViewModel,
        totalActivities: Int,
        totalMiles: Double,
        totalMovingHours: Double,
        totalElevationGainMeters: Double,
        totalKudos: Int,
        currentStreakDays: Int,
        longestStreakDays: Int,
        weeklyVolumes: [WeeklyVolume],
        trainingRhythm: [TrainingRhythmCell],
        maxRhythmCount: Int,
        typeBreakdown: [ActivityTypeBreakdown],
        peakDays: [PeakDay],
        peakActivities: [PeakActivity]
    ) {
        self.windowStart = windowStart
        self.windowEnd = windowEnd
        self.isPartial = isPartial
        self.heatmapDays = heatmapDays
        self.heatmapView = heatmapView
        self.totalActivities = totalActivities
        self.totalMiles = totalMiles
        self.totalMovingHours = totalMovingHours
        self.totalElevationGainMeters = totalElevationGainMeters
        self.totalKudos = totalKudos
        self.currentStreakDays = currentStreakDays
        self.longestStreakDays = longestStreakDays
        self.weeklyVolumes = weeklyVolumes
        self.trainingRhythm = trainingRhythm
        self.maxRhythmCount = maxRhythmCount
        self.typeBreakdown = typeBreakdown
        self.peakDays = peakDays
        self.peakActivities = peakActivities
    }
}
