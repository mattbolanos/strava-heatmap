import SwiftUI
import WidgetKit

struct HeatmapWidgetView: View {
    let entry: HeatmapEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        content
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
