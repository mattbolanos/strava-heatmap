import Foundation

public enum ActivityType: String, CaseIterable, Codable, Hashable, Sendable {
    // Foot sports
    case run = "Run"
    case trailRun = "TrailRun"
    case walk = "Walk"
    case hike = "Hike"
    case wheelchair = "Wheelchair"
    case virtualRun = "VirtualRun"

    // Cycle sports
    case ride = "Ride"
    case mountainBikeRide = "MountainBikeRide"
    case gravelRide = "GravelRide"
    case eBikeRide = "EBikeRide"
    case eMountainBikeRide = "EMountainBikeRide"
    case velomobile = "Velomobile"
    case handcycle = "Handcycle"
    case virtualRide = "VirtualRide"

    // Water sports
    case swim = "Swim"
    case rowing = "Rowing"
    case kayaking = "Kayaking"
    case canoeing = "Canoeing"
    case standUpPaddling = "StandUpPaddling"
    case surfing = "Surfing"
    case kitesurf = "Kitesurf"
    case windsurf = "Windsurf"
    case sail = "Sail"

    // Winter sports
    case alpineSki = "AlpineSki"
    case backcountrySki = "BackcountrySki"
    case nordicSki = "NordicSki"
    case snowboard = "Snowboard"
    case snowshoe = "Snowshoe"
    case iceSkate = "IceSkate"

    // Other distance sports
    case inlineSkate = "InlineSkate"
    case rollerSki = "RollerSki"
    case skateboard = "Skateboard"
    case soccer = "Soccer"
    case tennis = "Tennis"
    case padel = "Padel"
    case racquetball = "Racquetball"
    case squash = "Squash"
    case badminton = "Badminton"
    case pickleball = "Pickleball"
    case tableTennis = "TableTennis"
    case basketball = "Basketball"
    case volleyball = "Volleyball"
    case cricket = "Cricket"
    case dance = "Dance"
    case golf = "Golf"
    case elliptical = "Elliptical"

    public static let defaultSelected: Set<ActivityType> = [
        .run, .ride, .walk, .trailRun, .hike, .wheelchair
    ]

    public var displayName: String {
        switch self {
        case .run: return "Run"
        case .trailRun: return "Trail Run"
        case .walk: return "Walk"
        case .hike: return "Hike"
        case .wheelchair: return "Wheelchair"
        case .virtualRun: return "Virtual Run"
        case .ride: return "Ride"
        case .mountainBikeRide: return "Mountain Bike Ride"
        case .gravelRide: return "Gravel Ride"
        case .eBikeRide: return "E-Bike Ride"
        case .eMountainBikeRide: return "E-Mountain Bike Ride"
        case .velomobile: return "Velomobile"
        case .handcycle: return "Handcycle"
        case .virtualRide: return "Virtual Ride"
        case .swim: return "Swim"
        case .rowing: return "Rowing"
        case .kayaking: return "Kayaking"
        case .canoeing: return "Canoeing"
        case .standUpPaddling: return "Stand Up Paddling"
        case .surfing: return "Surfing"
        case .kitesurf: return "Kitesurf"
        case .windsurf: return "Windsurf"
        case .sail: return "Sailing"
        case .alpineSki: return "Alpine Ski"
        case .backcountrySki: return "Backcountry Ski"
        case .nordicSki: return "Nordic Ski"
        case .snowboard: return "Snowboard"
        case .snowshoe: return "Snowshoe"
        case .iceSkate: return "Ice Skate"
        case .inlineSkate: return "Inline Skate"
        case .rollerSki: return "Roller Ski"
        case .skateboard: return "Skateboard"
        case .soccer: return "Football (Soccer)"
        case .tennis: return "Tennis"
        case .padel: return "Padel"
        case .racquetball: return "Racquetball"
        case .squash: return "Squash"
        case .badminton: return "Badminton"
        case .pickleball: return "Pickleball"
        case .tableTennis: return "Table Tennis"
        case .basketball: return "Basketball"
        case .volleyball: return "Volleyball"
        case .cricket: return "Cricket"
        case .dance: return "Dance"
        case .golf: return "Golf"
        case .elliptical: return "Elliptical"
        }
    }

    /// SportType values (lowercased, underscores removed) that this case matches.
    public var matchingValues: Set<String> {
        switch self {
        case .run: return ["run"]
        case .trailRun: return ["trailrun"]
        case .walk: return ["walk"]
        case .hike: return ["hike"]
        case .wheelchair: return ["wheelchair"]
        case .virtualRun: return ["virtualrun"]
        case .ride: return ["ride"]
        case .mountainBikeRide: return ["mountainbikeride"]
        case .gravelRide: return ["gravelride"]
        case .eBikeRide: return ["ebikeride"]
        case .eMountainBikeRide: return ["emountainbikeride"]
        case .velomobile: return ["velomobile"]
        case .handcycle: return ["handcycle"]
        case .virtualRide: return ["virtualride"]
        case .swim: return ["swim"]
        case .rowing: return ["rowing", "virtualrow"]
        case .kayaking: return ["kayaking"]
        case .canoeing: return ["canoeing"]
        case .standUpPaddling: return ["standuppaddling"]
        case .surfing: return ["surfing"]
        case .kitesurf: return ["kitesurf"]
        case .windsurf: return ["windsurf"]
        case .sail: return ["sail"]
        case .alpineSki: return ["alpineski"]
        case .backcountrySki: return ["backcountryski"]
        case .nordicSki: return ["nordicski"]
        case .snowboard: return ["snowboard"]
        case .snowshoe: return ["snowshoe"]
        case .iceSkate: return ["iceskate"]
        case .inlineSkate: return ["inlineskate"]
        case .rollerSki: return ["rollerski"]
        case .skateboard: return ["skateboard"]
        case .soccer: return ["soccer"]
        case .tennis: return ["tennis"]
        case .padel: return ["padel"]
        case .racquetball: return ["racquetball"]
        case .squash: return ["squash"]
        case .badminton: return ["badminton"]
        case .pickleball: return ["pickleball"]
        case .tableTennis: return ["tabletennis"]
        case .basketball: return ["basketball"]
        case .volleyball: return ["volleyball"]
        case .cricket: return ["cricket"]
        case .dance: return ["dance"]
        case .golf: return ["golf"]
        case .elliptical: return ["elliptical"]
        }
    }

    /// Matches against a Strava activity's type and sportType fields.
    /// Prefers sportType (more specific) when available, falls back to type.
    public func matches(type: String, sportType: String) -> Bool {
        let normalizedSportType = sportType.lowercased().replacingOccurrences(of: "_", with: "")
        let normalizedType = type.lowercased().replacingOccurrences(of: "_", with: "")
        let candidate = normalizedSportType.isEmpty ? normalizedType : normalizedSportType
        return matchingValues.contains(candidate)
    }

    public enum Category: String, CaseIterable {
        case foot = "Foot Sports"
        case cycle = "Cycling"
        case water = "Water Sports"
        case winter = "Winter Sports"
        case other = "Other Sports"

        public var icon: String {
            switch self {
            case .foot: return "figure.run"
            case .cycle: return "figure.outdoor.cycle"
            case .water: return "figure.pool.swim"
            case .winter: return "snowflake"
            case .other: return "sportscourt"
            }
        }
    }

    public var category: Category {
        switch self {
        case .run, .trailRun, .walk, .hike, .wheelchair, .virtualRun:
            return .foot
        case .ride, .mountainBikeRide, .gravelRide, .eBikeRide, .eMountainBikeRide, .velomobile, .handcycle, .virtualRide:
            return .cycle
        case .swim, .rowing, .kayaking, .canoeing, .standUpPaddling, .surfing, .kitesurf, .windsurf, .sail:
            return .water
        case .alpineSki, .backcountrySki, .nordicSki, .snowboard, .snowshoe, .iceSkate:
            return .winter
        case .inlineSkate, .rollerSki, .skateboard, .soccer, .tennis, .padel, .racquetball, .squash, .badminton, .pickleball, .tableTennis, .basketball, .volleyball, .cricket, .dance, .golf, .elliptical:
            return .other
        }
    }

    public static func grouped() -> [(category: Category, types: [ActivityType])] {
        Category.allCases.map { category in
            (category: category, types: allCases.filter { $0.category == category })
        }
    }

    public static func defaultsValue(for selection: [ActivityType]) -> [String] {
        let source = selection.isEmpty ? Array(defaultSelected) : selection
        return source.map(\.rawValue)
    }
}
