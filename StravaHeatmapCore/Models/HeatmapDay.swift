import Foundation

public struct HeatmapDay: Codable, Hashable, Sendable {
    public let date: String
    public let miles: Double
    public let activityCount: Int
    public let distanceMeters: Double

    public init(date: String, miles: Double, activityCount: Int, distanceMeters: Double) {
        self.date = date
        self.miles = miles
        self.activityCount = activityCount
        self.distanceMeters = distanceMeters
    }
}
