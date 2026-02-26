import Foundation

public actor ActivityCache {
    public static let shared = ActivityCache()

    public struct CachedPayload: Codable, Sendable {
        public let fetchedAt: Date
        public let heatmapDays: [HeatmapDay]
        public let activities: [StravaActivity]?

        public init(fetchedAt: Date, heatmapDays: [HeatmapDay], activities: [StravaActivity]? = nil) {
            self.fetchedAt = fetchedAt
            self.heatmapDays = heatmapDays
            self.activities = activities
        }

        public func isFresh(maxAge: TimeInterval) -> Bool {
            Date().timeIntervalSince(fetchedAt) <= maxAge
        }
    }

    private struct Store: Codable {
        var buckets: [String: CachedPayload]
    }

    public init() {}

    public func read(selectedTypes: Set<ActivityType>) -> CachedPayload? {
        guard let url = cacheURL else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let decoded = try? JSONDecoder().decode(Store.self, from: data) else { return nil }
        return decoded.buckets[cacheKey(for: selectedTypes)]
    }

    public func write(
        heatmapDays: [HeatmapDay],
        selectedTypes: Set<ActivityType>,
        activities: [StravaActivity]? = nil
    ) {
        guard let url = cacheURL else { return }

        var store = (try? Data(contentsOf: url))
            .flatMap { try? JSONDecoder().decode(Store.self, from: $0) } ?? Store(buckets: [:])

        store.buckets[cacheKey(for: selectedTypes)] = CachedPayload(
            fetchedAt: Date(),
            heatmapDays: heatmapDays,
            activities: activities
        )

        if let encoded = try? JSONEncoder().encode(store) {
            try? encoded.write(to: url, options: [.atomic])
        }
    }

    public func clear() {
        guard let url = cacheURL else { return }
        try? FileManager.default.removeItem(at: url)
    }

    private func cacheKey(for selectedTypes: Set<ActivityType>) -> String {
        selectedTypes.map(\.rawValue).sorted().joined(separator: ",")
    }

    private var cacheURL: URL? {
        let fm = FileManager.default
        guard let container = fm.containerURL(forSecurityApplicationGroupIdentifier: SharedConstants.appGroupIdentifier) else {
            return nil
        }
        return container.appendingPathComponent(SharedConstants.cacheFileName)
    }
}
