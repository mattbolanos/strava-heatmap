import Foundation

public enum ActivityInsightsBuilder {
    private static let metersPerMile = 1_609.344
    private static let feetPerMeter = 3.28084

    public static func build(
        activities: [StravaActivity],
        windowEnd: Date = Date(),
        windowDays: Int = 366,
        weeksToShow: Int = 52,
        peakDayLimit: Int = 8,
        peakActivityLimit: Int = 12
    ) -> ActivityInsights {
        let calendar = configuredCalendar()
        let utcCalendar = utcConfiguredCalendar()
        let endDay = calendar.startOfDay(for: windowEnd)
        let startDay = calendar.date(byAdding: .day, value: -(windowDays - 1), to: endDay) ?? endDay

        var daily: [String: DayAggregate] = [:]
        var rhythm: [RhythmKey: RhythmAggregate] = [:]
        var typeCounts: [ActivityType: Int] = [:]

        var totalMeters = 0.0
        var totalMovingSeconds = 0
        var totalElevationGain = 0.0
        var totalKudos = 0
        var totalActivities = 0

        for activity in activities {
            let localDay = calendar.startOfDay(for: activity.startDateLocal)
            guard localDay >= startDay, localDay <= endDay else {
                continue
            }

            let dayKey = HeatmapBuilder.toDateKey(localDay)
            var aggregate = daily[dayKey] ?? DayAggregate(date: localDay)
            aggregate.distanceMeters += activity.distance
            aggregate.activityCount += 1
            aggregate.elevationGainMeters += activity.totalElevationGain
            aggregate.kudosCount += activity.kudosCount
            aggregate.movingSeconds += activity.movingTime
            daily[dayKey] = aggregate

            // startDateLocal is local time encoded as UTC by Strava,
            // so use a UTC calendar to extract correct hour/weekday.
            let weekday = utcCalendar.component(.weekday, from: activity.startDateLocal)
            let hour = utcCalendar.component(.hour, from: activity.startDateLocal)
            let rhythmKey = RhythmKey(weekday: weekday, hour: hour)
            var rhythmValue = rhythm[rhythmKey] ?? RhythmAggregate()
            rhythmValue.activityCount += 1
            rhythmValue.movingSeconds += activity.movingTime
            rhythm[rhythmKey] = rhythmValue

            if let matchedType = ActivityType.allCases.first(where: {
                $0.matches(type: activity.type, sportType: activity.sportType)
            }) {
                typeCounts[matchedType, default: 0] += 1
            }

            totalMeters += activity.distance
            totalMovingSeconds += activity.movingTime
            totalElevationGain += activity.totalElevationGain
            totalKudos += activity.kudosCount
            totalActivities += 1
        }

        let heatmapDays = makeHeatmapDays(from: daily)
        let heatmapView = HeatmapBuilder.buildHeatmapView(heatmap: heatmapDays, weeksToShow: weeksToShow)
        let activeDays = Set(daily.keys)

        let pacePoints = makePacePoints(from: activities, startDay: startDay, endDay: endDay, calendar: calendar)
        let (effortPoints, weeklyEffort) = makeEffortData(from: activities, startDay: startDay, endDay: endDay, calendar: calendar)

        return ActivityInsights(
            windowStart: startDay,
            windowEnd: endDay,
            isPartial: false,
            heatmapDays: heatmapDays,
            heatmapView: heatmapView,
            totalActivities: totalActivities,
            totalMiles: round(totalMeters / metersPerMile, places: 2),
            totalMovingHours: round(Double(totalMovingSeconds) / 3_600, places: 1),
            totalElevationGainMeters: round(totalElevationGain * feetPerMeter, places: 0),
            totalKudos: totalKudos,
            currentStreakDays: streakEnding(on: endDay, startDay: startDay, activeDayKeys: activeDays, calendar: calendar),
            longestStreakDays: longestStreak(from: startDay, to: endDay, activeDayKeys: activeDays, calendar: calendar),
            weeklyVolumes: makeWeeklyVolumes(from: daily, calendar: calendar),
            trainingRhythm: makeTrainingRhythm(from: rhythm),
            maxRhythmCount: rhythm.values.map(\.activityCount).max() ?? 0,
            typeBreakdown: makeTypeBreakdown(from: typeCounts, totalActivities: totalActivities),
            peakDays: makePeakDays(from: daily, limit: peakDayLimit),
            peakActivities: makePeakActivities(from: activities, startDay: startDay, endDay: endDay, calendar: calendar, limit: peakActivityLimit),
            pacePoints: pacePoints,
            effortPoints: effortPoints,
            weeklyEffort: weeklyEffort
        )
    }

    public static func buildPartial(
        heatmapDays: [HeatmapDay],
        windowEnd: Date = Date(),
        windowDays: Int = 366,
        weeksToShow: Int = 52,
        peakDayLimit: Int = 8
    ) -> ActivityInsights {
        let calendar = configuredCalendar()
        let endDay = calendar.startOfDay(for: windowEnd)
        let startDay = calendar.date(byAdding: .day, value: -(windowDays - 1), to: endDay) ?? endDay

        let daily = makeDayAggregates(from: heatmapDays, calendar: calendar)
        let heatmapView = HeatmapBuilder.buildHeatmapView(heatmap: heatmapDays, weeksToShow: weeksToShow)
        let activeDays = Set(daily.keys)

        let totalActivities = heatmapDays.reduce(0) { $0 + $1.activityCount }
        let totalMiles = heatmapDays.reduce(0.0) { $0 + $1.miles }

        return ActivityInsights(
            windowStart: startDay,
            windowEnd: endDay,
            isPartial: true,
            heatmapDays: heatmapDays,
            heatmapView: heatmapView,
            totalActivities: totalActivities,
            totalMiles: round(totalMiles, places: 2),
            totalMovingHours: 0,
            totalElevationGainMeters: 0,
            totalKudos: 0,
            currentStreakDays: streakEnding(on: endDay, startDay: startDay, activeDayKeys: activeDays, calendar: calendar),
            longestStreakDays: longestStreak(from: startDay, to: endDay, activeDayKeys: activeDays, calendar: calendar),
            weeklyVolumes: makeWeeklyVolumes(from: daily, calendar: calendar),
            trainingRhythm: [],
            maxRhythmCount: 0,
            typeBreakdown: [],
            peakDays: makePeakDays(from: daily, limit: peakDayLimit),
            peakActivities: []
        )
    }

    private static func makeHeatmapDays(from daily: [String: DayAggregate]) -> [HeatmapDay] {
        daily
            .map { key, aggregate in
                HeatmapDay(
                    date: key,
                    miles: round(aggregate.distanceMeters / metersPerMile, places: 2),
                    activityCount: aggregate.activityCount,
                    distanceMeters: aggregate.distanceMeters
                )
            }
            .sorted { $0.date < $1.date }
    }

    private static func makeDayAggregates(from heatmapDays: [HeatmapDay], calendar: Calendar) -> [String: DayAggregate] {
        var result: [String: DayAggregate] = [:]

        for day in heatmapDays {
            guard let date = fromDateKey(day.date, calendar: calendar) else {
                continue
            }

            result[day.date] = DayAggregate(
                date: date,
                distanceMeters: day.distanceMeters,
                activityCount: day.activityCount,
                elevationGainMeters: 0,
                kudosCount: 0,
                movingSeconds: 0
            )
        }

        return result
    }

    private static func makeWeeklyVolumes(from daily: [String: DayAggregate], calendar: Calendar) -> [WeeklyVolume] {
        var weekly: [Date: WeeklyAggregate] = [:]

        for aggregate in daily.values {
            let weekStart = startOfWeek(for: aggregate.date, calendar: calendar)
            var bucket = weekly[weekStart] ?? WeeklyAggregate()
            bucket.distanceMeters += aggregate.distanceMeters
            bucket.activeDays += aggregate.activityCount > 0 ? 1 : 0
            bucket.activityCount += aggregate.activityCount
            weekly[weekStart] = bucket
        }

        return weekly
            .map { weekStart, bucket in
                WeeklyVolume(
                    weekStart: weekStart,
                    miles: round(bucket.distanceMeters / metersPerMile, places: 2),
                    activeDays: bucket.activeDays,
                    activityCount: bucket.activityCount
                )
            }
            .sorted { $0.weekStart < $1.weekStart }
    }

    private static func makePeakDays(from daily: [String: DayAggregate], limit: Int) -> [PeakDay] {
        daily
            .map { key, aggregate in
                PeakDay(
                    date: aggregate.date,
                    dateKey: key,
                    miles: round(aggregate.distanceMeters / metersPerMile, places: 2),
                    activityCount: aggregate.activityCount,
                    elevationGainMeters: round(aggregate.elevationGainMeters, places: 0),
                    kudosCount: aggregate.kudosCount
                )
            }
            .sorted { lhs, rhs in
                if lhs.miles != rhs.miles {
                    return lhs.miles > rhs.miles
                }
                if lhs.activityCount != rhs.activityCount {
                    return lhs.activityCount > rhs.activityCount
                }
                return lhs.date > rhs.date
            }
            .prefix(limit)
            .map { $0 }
    }

    private static func makePeakActivities(
        from activities: [StravaActivity],
        startDay: Date,
        endDay: Date,
        calendar: Calendar,
        limit: Int
    ) -> [PeakActivity] {
        activities
            .filter {
                let localDay = calendar.startOfDay(for: $0.startDateLocal)
                return localDay >= startDay && localDay <= endDay
            }
            .sorted { $0.distance > $1.distance }
            .prefix(limit)
            .map { activity in
                let matchedType = ActivityType.allCases.first {
                    $0.matches(type: activity.type, sportType: activity.sportType)
                }
                return PeakActivity(
                    id: activity.id,
                    name: activity.name,
                    date: activity.startDateLocal,
                    miles: round(activity.distance / metersPerMile, places: 2),
                    elevationGainMeters: round(activity.totalElevationGain * feetPerMeter, places: 0),
                    kudosCount: activity.kudosCount,
                    movingTimeSeconds: activity.movingTime,
                    activityType: matchedType
                )
            }
    }

    private static func makeTrainingRhythm(from rhythm: [RhythmKey: RhythmAggregate]) -> [TrainingRhythmCell] {
        rhythm
            .map { key, value in
                TrainingRhythmCell(
                    weekday: key.weekday,
                    hour: key.hour,
                    activityCount: value.activityCount,
                    movingSeconds: value.movingSeconds
                )
            }
            .sorted { lhs, rhs in
                if lhs.weekday != rhs.weekday {
                    return lhs.weekday < rhs.weekday
                }
                return lhs.hour < rhs.hour
            }
    }

    private static func makeTypeBreakdown(from counts: [ActivityType: Int], totalActivities: Int) -> [ActivityTypeBreakdown] {
        guard totalActivities > 0 else {
            return []
        }

        return counts
            .map { type, count in
                ActivityTypeBreakdown(
                    type: type,
                    activityCount: count,
                    share: Double(count) / Double(totalActivities)
                )
            }
            .sorted { lhs, rhs in
                if lhs.activityCount != rhs.activityCount {
                    return lhs.activityCount > rhs.activityCount
                }
                return lhs.type.displayName < rhs.type.displayName
            }
    }

    private static func streakEnding(on endDay: Date, startDay: Date, activeDayKeys: Set<String>, calendar: Calendar) -> Int {
        var streak = 0
        var day = endDay

        while day >= startDay {
            let key = HeatmapBuilder.toDateKey(day)
            guard activeDayKeys.contains(key) else {
                break
            }

            streak += 1
            day = calendar.date(byAdding: .day, value: -1, to: day) ?? day
        }

        return streak
    }

    private static func longestStreak(from startDay: Date, to endDay: Date, activeDayKeys: Set<String>, calendar: Calendar) -> Int {
        var longest = 0
        var current = 0
        var day = startDay

        while day <= endDay {
            if activeDayKeys.contains(HeatmapBuilder.toDateKey(day)) {
                current += 1
                longest = max(longest, current)
            } else {
                current = 0
            }

            day = calendar.date(byAdding: .day, value: 1, to: day) ?? day
        }

        return longest
    }

    private static func startOfWeek(for date: Date, calendar: Calendar) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let delta = -(weekday - 1)
        let weekStart = calendar.date(byAdding: .day, value: delta, to: date) ?? date
        return calendar.startOfDay(for: weekStart)
    }

    private static func fromDateKey(_ key: String, calendar: Calendar) -> Date? {
        let parts = key.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else {
            return nil
        }

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = .current
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components)
    }

    private static func configuredCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }

    private static func utcConfiguredCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }


    private static func makePacePoints(
        from activities: [StravaActivity],
        startDay: Date,
        endDay: Date,
        calendar: Calendar
    ) -> [PacePoint] {
        activities
            .filter {
                let localDay = calendar.startOfDay(for: $0.startDateLocal)
                return localDay >= startDay && localDay <= endDay
                    && $0.distance > 500 && $0.movingTime > 0
            }
            .map { activity in
                let miles = activity.distance / metersPerMile
                let paceSecondsPerMile = Double(activity.movingTime) / miles
                let matchedType = ActivityType.allCases.first {
                    $0.matches(type: activity.type, sportType: activity.sportType)
                }
                return PacePoint(
                    date: activity.startDateLocal,
                    paceSecondsPerMile: paceSecondsPerMile,
                    activityName: activity.name,
                    miles: round(miles, places: 2),
                    activityType: matchedType
                )
            }
            .sorted { $0.date < $1.date }
    }

    private static func makeEffortData(
        from activities: [StravaActivity],
        startDay: Date,
        endDay: Date,
        calendar: Calendar
    ) -> (effortPoints: [EffortPoint], weeklyEffort: [WeeklyEffort]) {
        let filtered = activities.filter {
            let localDay = calendar.startOfDay(for: $0.startDateLocal)
            return localDay >= startDay && localDay <= endDay
                && ($0.sufferScore ?? 0) > 0
        }

        let effortPoints = filtered
            .map { EffortPoint(date: $0.startDateLocal, sufferScore: $0.sufferScore!, activityName: $0.name) }
            .sorted { $0.date < $1.date }

        var weeklyBuckets: [Date: (total: Int, count: Int)] = [:]
        for activity in filtered {
            let weekStart = startOfWeek(for: calendar.startOfDay(for: activity.startDateLocal), calendar: calendar)
            var bucket = weeklyBuckets[weekStart] ?? (total: 0, count: 0)
            bucket.total += activity.sufferScore!
            bucket.count += 1
            weeklyBuckets[weekStart] = bucket
        }

        let weeklyEffort = weeklyBuckets
            .map { WeeklyEffort(weekStart: $0.key, totalSufferScore: $0.value.total, activityCount: $0.value.count) }
            .sorted { $0.weekStart < $1.weekStart }

        return (effortPoints, weeklyEffort)
    }

    private static func round(_ value: Double, places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (value * factor).rounded() / factor
    }
}

private struct DayAggregate {
    let date: Date
    var distanceMeters: Double
    var activityCount: Int
    var elevationGainMeters: Double
    var kudosCount: Int
    var movingSeconds: Int

    init(
        date: Date,
        distanceMeters: Double = 0,
        activityCount: Int = 0,
        elevationGainMeters: Double = 0,
        kudosCount: Int = 0,
        movingSeconds: Int = 0
    ) {
        self.date = date
        self.distanceMeters = distanceMeters
        self.activityCount = activityCount
        self.elevationGainMeters = elevationGainMeters
        self.kudosCount = kudosCount
        self.movingSeconds = movingSeconds
    }
}

private struct WeeklyAggregate {
    var distanceMeters: Double = 0
    var activeDays: Int = 0
    var activityCount: Int = 0
}

private struct RhythmKey: Hashable {
    let weekday: Int
    let hour: Int
}

private struct RhythmAggregate {
    var activityCount: Int = 0
    var movingSeconds: Int = 0
}
