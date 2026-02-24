import Foundation

public struct StravaActivity: Codable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let distance: Double
    public let movingTime: Int
    public let elapsedTime: Int
    public let type: String
    public let sportType: String
    public let startDate: Date
    public let startDateLocal: Date
    public let totalElevationGain: Double
    public let kudosCount: Int

    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case distance
        case movingTime = "moving_time"
        case elapsedTime = "elapsed_time"
        case type
        case sportType = "sport_type"
        case startDate = "start_date"
        case startDateLocal = "start_date_local"
        case totalElevationGain = "total_elevation_gain"
        case kudosCount = "kudos_count"
    }

    public init(
        id: Int,
        name: String,
        distance: Double,
        movingTime: Int,
        elapsedTime: Int,
        type: String,
        sportType: String,
        startDate: Date,
        startDateLocal: Date,
        totalElevationGain: Double,
        kudosCount: Int
    ) {
        self.id = id
        self.name = name
        self.distance = distance
        self.movingTime = movingTime
        self.elapsedTime = elapsedTime
        self.type = type
        self.sportType = sportType
        self.startDate = startDate
        self.startDateLocal = startDateLocal
        self.totalElevationGain = totalElevationGain
        self.kudosCount = kudosCount
    }
}
