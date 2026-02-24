import AppIntents
import StratilesCore

struct SelectActivityTypesIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Activity Types"
    static var description = IntentDescription("Choose which activity types are shown in the heatmap.")

    @Parameter(title: "Types", default: [.run, .ride, .walk, .trailRun, .hike, .wheelchair])
    var activityTypes: [WidgetActivityType]
}
