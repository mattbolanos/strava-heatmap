import Foundation

public actor StravaAPIClient {
    public static let shared = StravaAPIClient()

    private let metersPerMile = 1_609.344
    private let tokenManager: TokenManager
    private var refreshTask: Task<String, Error>?

    public init(tokenManager: TokenManager = .shared) {
        self.tokenManager = tokenManager
    }

    public func exchangeAuthorizationCode(_ code: String) async throws -> StravaToken {
        let config = try StravaConfiguration.current()
        var request = URLRequest(url: URL(string: "https://www.strava.com/oauth/token")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "client_id": config.clientID,
            "client_secret": config.clientSecret,
            "code": code,
            "grant_type": "authorization_code",
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await requestData(request: request, retries: 2)
        guard (200..<300).contains(response.statusCode) else {
            throw StravaAPIClientError.httpStatus(response.statusCode)
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        let token = tokenResponse.asToken
        try await tokenManager.saveToken(token)
        return token
    }

    public func getAccessToken(forceRefresh: Bool = false) async throws -> String {
        guard let token = await tokenManager.loadToken() else {
            throw StravaAPIClientError.missingToken
        }

        if !forceRefresh && !token.isExpired {
            return token.accessToken
        }

        if let refreshTask {
            return try await refreshTask.value
        }

        let task = Task<String, Error> {
            let refreshed = try await refreshAccessToken(using: token.refreshToken)
            try await tokenManager.saveToken(refreshed)
            return refreshed.accessToken
        }

        refreshTask = task

        defer { refreshTask = nil }
        return try await task.value
    }

    public func fetchActivities(
        selectedTypes: Set<ActivityType>,
        maxPages: Int = 8,
        perPage: Int = 100,
        after: Date
    ) async throws -> [HeatmapDay] {
        let raw = try await fetchRawActivities(
            selectedTypes: selectedTypes,
            maxPages: maxPages,
            perPage: perPage,
            after: after
        )
        return aggregateByDay(raw)
    }

    public func fetchRawActivities(
        selectedTypes: Set<ActivityType>,
        maxPages: Int = 8,
        perPage: Int = 100,
        after: Date
    ) async throws -> [StravaActivity] {
        var accessToken = try await getAccessToken()
        var seenActivityIDs = Set<Int>()
        var filteredActivities: [StravaActivity] = []

        let selected = selectedTypes.isEmpty ? Set([ActivityType.run]) : selectedTypes

        for page in 1...maxPages {
            let url = buildActivitiesURL(after: after, page: page, perPage: perPage)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            var (data, response) = try await requestData(request: request, retries: 3)

            if response.statusCode == 401 {
                accessToken = try await getAccessToken(forceRefresh: true)
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                (data, response) = try await requestData(request: request, retries: 3)
            }

            guard (200..<300).contains(response.statusCode) else {
                if page == 1 && filteredActivities.isEmpty {
                    throw StravaAPIClientError.httpStatus(response.statusCode)
                }
                break
            }

            let pageActivities = try decodeActivities(from: data)

            for activity in pageActivities {
                guard !seenActivityIDs.contains(activity.id) else { continue }
                guard selected.contains(where: { $0.matches(type: activity.type, sportType: activity.sportType) }) else {
                    continue
                }

                seenActivityIDs.insert(activity.id)
                filteredActivities.append(activity)
            }

            if pageActivities.count < perPage {
                break
            }
        }

        return filteredActivities
    }

    private func buildActivitiesURL(after: Date, page: Int, perPage: Int) -> URL {
        var components = URLComponents(string: "https://www.strava.com/api/v3/athlete/activities")!
        components.queryItems = [
            URLQueryItem(name: "after", value: String(Int(after.timeIntervalSince1970))),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage)),
        ]
        return components.url!
    }

    private func refreshAccessToken(using refreshToken: String) async throws -> StravaToken {
        let config = try StravaConfiguration.current()
        var request = URLRequest(url: URL(string: "https://www.strava.com/oauth/token")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "client_id": config.clientID,
            "client_secret": config.clientSecret,
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await requestData(request: request, retries: 3)
        guard (200..<300).contains(response.statusCode) else {
            throw StravaAPIClientError.httpStatus(response.statusCode)
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        return tokenResponse.asToken
    }

    private func decodeActivities(from data: Data) throws -> [StravaActivity] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let activities = try? decoder.decode([StravaActivity].self, from: data) {
            return activities
        }

        if let raw = try JSONSerialization.jsonObject(with: data) as? [Any] {
            var result: [StravaActivity] = []
            for value in raw {
                let itemData = try JSONSerialization.data(withJSONObject: value)
                if let decoded = try? decoder.decode(StravaActivity.self, from: itemData) {
                    result.append(decoded)
                }
            }
            return result
        }

        return []
    }

    private func aggregateByDay(_ activities: [StravaActivity]) -> [HeatmapDay] {
        var byDay: [String: (distanceMeters: Double, activityCount: Int)] = [:]

        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for activity in activities {
            let dayKey = dateFormatter.string(from: activity.startDateLocal)
            var existing = byDay[dayKey] ?? (distanceMeters: 0, activityCount: 0)
            existing.distanceMeters += activity.distance
            existing.activityCount += 1
            byDay[dayKey] = existing
        }

        return byDay
            .map { date, values in
                HeatmapDay(
                    date: date,
                    miles: round(values.distanceMeters / metersPerMile, places: 2),
                    activityCount: values.activityCount,
                    distanceMeters: values.distanceMeters
                )
            }
            .sorted { $0.date < $1.date }
    }

    private func requestData(request: URLRequest, retries: Int) async throws -> (Data, HTTPURLResponse) {
        for attempt in 0...retries {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse else {
                    throw StravaAPIClientError.invalidResponse
                }

                if isRetriable(status: http.statusCode), attempt < retries {
                    let delay = retryDelayMs(for: attempt, retryAfterHeader: http.value(forHTTPHeaderField: "retry-after"))
                    try await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000)
                    continue
                }

                return (data, http)
            } catch {
                if attempt >= retries {
                    throw error
                }
                let delay = min(250 * Int(pow(2.0, Double(attempt))), 8_000)
                try await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000)
            }
        }

        throw StravaAPIClientError.requestFailed
    }

    private func isRetriable(status: Int) -> Bool {
        status == 408 || status == 429 || (500...599).contains(status)
    }

    private func retryDelayMs(for attempt: Int, retryAfterHeader: String?) -> Int {
        if let retryAfterHeader,
           let retryAfterSeconds = Double(retryAfterHeader),
           retryAfterSeconds >= 0 {
            return min(Int(retryAfterSeconds * 1_000), 8_000)
        }

        return min(250 * Int(pow(2.0, Double(attempt))), 8_000)
    }

    private func round(_ value: Double, places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (value * factor).rounded() / factor
    }
}

public enum StravaAPIClientError: Error {
    case missingToken
    case missingConfiguration
    case invalidResponse
    case requestFailed
    case httpStatus(Int)
}

public struct StravaConfiguration: Sendable {
    public let clientID: String
    public let clientSecret: String

    public static let callbackURLScheme = "stratiles"
    public static let callbackURL = "stratiles://localhost/callback"

    public static func current(bundle: Bundle = .main) throws -> StravaConfiguration {
        guard let clientID = bundle.object(forInfoDictionaryKey: "STRAVA_CLIENT_ID") as? String,
              let clientSecret = bundle.object(forInfoDictionaryKey: "STRAVA_CLIENT_SECRET") as? String,
              !clientID.isEmpty,
              !clientSecret.isEmpty else {
            throw StravaAPIClientError.missingConfiguration
        }

        return StravaConfiguration(clientID: clientID, clientSecret: clientSecret)
    }
}

private struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: TimeInterval

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
    }

    var asToken: StravaToken {
        StravaToken(accessToken: accessToken, refreshToken: refreshToken, expiresAt: expiresAt)
    }
}
