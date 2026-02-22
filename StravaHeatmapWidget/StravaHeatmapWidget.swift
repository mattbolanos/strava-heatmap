import SwiftUI
import WidgetKit

struct StravaHeatmapWidget: Widget {
    let kind: String = "StravaHeatmapWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectActivityTypesIntent.self,
            provider: HeatmapTimelineProvider()
        ) { entry in
            HeatmapWidgetView(entry: entry)
        }
        .configurationDisplayName("Stratiles")
        .description("GitHub-style contribution heatmap for your selected Strava activity types.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}
