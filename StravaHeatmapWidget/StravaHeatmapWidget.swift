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
                .containerBackground(for: .widget) {
                    HeatmapWidgetStyle.backgroundColor
                }
        }
        .configurationDisplayName("Strava Heatmap")
        .description("GitHub-style contribution heatmap for your selected Strava activity types.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
        .containerBackgroundRemovable(false)
    }
}
