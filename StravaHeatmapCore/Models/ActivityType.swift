import Foundation

public enum ActivityType: String, CaseIterable, Codable, Hashable, Sendable {
    case run = "Run"
    case ride = "Ride"
    case swim = "Swim"
    case walk = "Walk"
    case hike = "Hike"
    case virtualRide = "VirtualRide"
    case virtualRun = "VirtualRun"
    case weightTraining = "WeightTraining"
    case yoga = "Yoga"

    public var displayName: String {
        switch self {
        case .run: return "Run"
        case .ride: return "Ride"
        case .swim: return "Swim"
        case .walk: return "Walk"
        case .hike: return "Hike"
        case .virtualRide: return "Virtual Ride"
        case .virtualRun: return "Virtual Run"
        case .weightTraining: return "Weight Training"
        case .yoga: return "Yoga"
        }
    }

    public var matchingValues: Set<String> {
        switch self {
        case .run:
            return ["run"]
        case .ride:
            return ["ride"]
        case .swim:
            return ["swim"]
        case .walk:
            return ["walk"]
        case .hike:
            return ["hike"]
        case .virtualRide:
            return ["virtualride", "virtual ride"]
        case .virtualRun:
            return ["virtualrun", "virtual run"]
        case .weightTraining:
            return ["weighttraining", "weight training"]
        case .yoga:
            return ["yoga"]
        }
    }

    public func matches(type: String, sportType: String) -> Bool {
        let candidates = [type, sportType].map {
            $0.lowercased().replacingOccurrences(of: "_", with: "")
        }
        return !matchingValues.isDisjoint(with: Set(candidates))
    }

    public static func defaultsValue(for selection: [ActivityType]) -> [String] {
        let source = selection.isEmpty ? [ActivityType.run] : selection
        return source.map(\.rawValue)
    }
}

