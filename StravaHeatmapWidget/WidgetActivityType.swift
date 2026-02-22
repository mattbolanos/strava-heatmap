import AppIntents
import StravaHeatmapCore

/// Local mirror of `ActivityType` that lives in the widget target so WidgetKit
/// can discover the `AppEnum` cases during out-of-process configuration.
enum WidgetActivityType: String, AppEnum, CaseIterable {
    case run = "Run"
    case ride = "Ride"
    case swim = "Swim"
    case walk = "Walk"
    case hike = "Hike"
    case virtualRide = "VirtualRide"
    case virtualRun = "VirtualRun"
    case weightTraining = "WeightTraining"
    case yoga = "Yoga"

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Activity Type")
    }

    static var caseDisplayRepresentations: [WidgetActivityType: DisplayRepresentation] {
        [
            .run: DisplayRepresentation(title: "Run"),
            .ride: DisplayRepresentation(title: "Ride"),
            .swim: DisplayRepresentation(title: "Swim"),
            .walk: DisplayRepresentation(title: "Walk"),
            .hike: DisplayRepresentation(title: "Hike"),
            .virtualRide: DisplayRepresentation(title: "Virtual Ride"),
            .virtualRun: DisplayRepresentation(title: "Virtual Run"),
            .weightTraining: DisplayRepresentation(title: "Weight Training"),
            .yoga: DisplayRepresentation(title: "Yoga"),
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
