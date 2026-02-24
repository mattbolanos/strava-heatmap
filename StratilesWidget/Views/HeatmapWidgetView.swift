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
            .clipShape(.rect(cornerRadius: containerCornerRadius, style: .continuous))
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

    private var containerCornerRadius: CGFloat {
        switch family {
        case .systemSmall:
            return 28
        case .systemMedium:
            return 24
        default:
            return 24
        }
    }
}
