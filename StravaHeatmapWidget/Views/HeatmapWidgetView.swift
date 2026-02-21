import SwiftUI
import WidgetKit

struct HeatmapWidgetView: View {
    let entry: HeatmapEntry

    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode

    var body: some View {
        content
            .containerBackground(for: .widget) {
                if widgetRenderingMode == .fullColor {
                    HeatmapWidgetStyle.legacyBackgroundGradient
                } else {
                    Color.clear
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemSmall:
            SmallHeatmapView(entry: entry)
        case .systemMedium:
            MediumHeatmapView(entry: entry)
        default:
            SmallHeatmapView(entry: entry)
        }
    }
}
