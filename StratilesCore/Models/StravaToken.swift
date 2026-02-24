import Foundation

public struct StravaToken: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresAt: TimeInterval

    public init(accessToken: String, refreshToken: String, expiresAt: TimeInterval) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }

    public var isExpired: Bool {
        expiresAt <= Date().addingTimeInterval(120).timeIntervalSince1970
    }
}
