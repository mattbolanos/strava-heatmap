import SwiftUI
import WidgetKit

struct StratilesWidget: Widget {
    let kind: String = "StratilesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
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
