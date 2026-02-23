import AppIntents
import StravaHeatmapCore

/// Local mirror of `ActivityType` that lives in the widget target so WidgetKit
/// can discover the `AppEnum` cases during out-of-process configuration.
enum WidgetActivityType: String, AppEnum, CaseIterable {
    case run = "Run"
    case trailRun = "TrailRun"
    case walk = "Walk"
    case hike = "Hike"
    case wheelchair = "Wheelchair"
    case virtualRun = "VirtualRun"
    case ride = "Ride"
    case mountainBikeRide = "MountainBikeRide"
    case gravelRide = "GravelRide"
    case eBikeRide = "EBikeRide"
    case eMountainBikeRide = "EMountainBikeRide"
    case velomobile = "Velomobile"
    case handcycle = "Handcycle"
    case virtualRide = "VirtualRide"
    case swim = "Swim"
    case rowing = "Rowing"
    case kayaking = "Kayaking"
    case canoeing = "Canoeing"
    case standUpPaddling = "StandUpPaddling"
    case surfing = "Surfing"
    case kitesurf = "Kitesurf"
    case windsurf = "Windsurf"
    case sail = "Sail"
    case alpineSki = "AlpineSki"
    case backcountrySki = "BackcountrySki"
    case nordicSki = "NordicSki"
    case snowboard = "Snowboard"
    case snowshoe = "Snowshoe"
    case iceSkate = "IceSkate"
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

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Activity Type")
    }

    static var caseDisplayRepresentations: [WidgetActivityType: DisplayRepresentation] {
        [
            .run: DisplayRepresentation(title: "Run"),
            .trailRun: DisplayRepresentation(title: "Trail Run"),
            .walk: DisplayRepresentation(title: "Walk"),
            .hike: DisplayRepresentation(title: "Hike"),
            .wheelchair: DisplayRepresentation(title: "Wheelchair"),
            .virtualRun: DisplayRepresentation(title: "Virtual Run"),
            .ride: DisplayRepresentation(title: "Ride"),
            .mountainBikeRide: DisplayRepresentation(title: "Mountain Bike Ride"),
            .gravelRide: DisplayRepresentation(title: "Gravel Ride"),
            .eBikeRide: DisplayRepresentation(title: "E-Bike Ride"),
            .eMountainBikeRide: DisplayRepresentation(title: "E-Mountain Bike Ride"),
            .velomobile: DisplayRepresentation(title: "Velomobile"),
            .handcycle: DisplayRepresentation(title: "Handcycle"),
            .virtualRide: DisplayRepresentation(title: "Virtual Ride"),
            .swim: DisplayRepresentation(title: "Swim"),
            .rowing: DisplayRepresentation(title: "Rowing"),
            .kayaking: DisplayRepresentation(title: "Kayaking"),
            .canoeing: DisplayRepresentation(title: "Canoeing"),
            .standUpPaddling: DisplayRepresentation(title: "Stand Up Paddling"),
            .surfing: DisplayRepresentation(title: "Surfing"),
            .kitesurf: DisplayRepresentation(title: "Kitesurf"),
            .windsurf: DisplayRepresentation(title: "Windsurf"),
            .sail: DisplayRepresentation(title: "Sailing"),
            .alpineSki: DisplayRepresentation(title: "Alpine Ski"),
            .backcountrySki: DisplayRepresentation(title: "Backcountry Ski"),
            .nordicSki: DisplayRepresentation(title: "Nordic Ski"),
            .snowboard: DisplayRepresentation(title: "Snowboard"),
            .snowshoe: DisplayRepresentation(title: "Snowshoe"),
            .iceSkate: DisplayRepresentation(title: "Ice Skate"),
            .inlineSkate: DisplayRepresentation(title: "Inline Skate"),
            .rollerSki: DisplayRepresentation(title: "Roller Ski"),
            .skateboard: DisplayRepresentation(title: "Skateboard"),
            .soccer: DisplayRepresentation(title: "Football (Soccer)"),
            .tennis: DisplayRepresentation(title: "Tennis"),
            .padel: DisplayRepresentation(title: "Padel"),
            .racquetball: DisplayRepresentation(title: "Racquetball"),
            .squash: DisplayRepresentation(title: "Squash"),
            .badminton: DisplayRepresentation(title: "Badminton"),
            .pickleball: DisplayRepresentation(title: "Pickleball"),
            .tableTennis: DisplayRepresentation(title: "Table Tennis"),
            .basketball: DisplayRepresentation(title: "Basketball"),
            .volleyball: DisplayRepresentation(title: "Volleyball"),
            .cricket: DisplayRepresentation(title: "Cricket"),
            .dance: DisplayRepresentation(title: "Dance"),
            .golf: DisplayRepresentation(title: "Golf"),
            .elliptical: DisplayRepresentation(title: "Elliptical"),
        ]
    }

    var toCoreType: ActivityType {
        ActivityType(rawValue: rawValue)!
    }

    init(from coreType: ActivityType) {
        self.init(rawValue: coreType.rawValue)!
    }
}

extension Array where Element == WidgetActivityType {
    var toCoreTypes: [ActivityType] {
        map(\.toCoreType)
    }
}
