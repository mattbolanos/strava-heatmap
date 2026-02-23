import AppIntents
import StravaHeatmapCore

struct SelectActivityTypesIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Activity Types"
    static var description = IntentDescription("Choose which Strava activity types are shown in the heatmap.")

    @Parameter(title: "Types", default: [.run, .ride, .walk, .trailRun, .hike, .wheelchair])
    var activityTypes: [WidgetActivityType]
}
