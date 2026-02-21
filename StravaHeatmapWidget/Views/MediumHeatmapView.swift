import SwiftUI
import StravaHeatmapCore
import WidgetKit

struct MediumHeatmapView: View {
    let entry: HeatmapEntry

    @Environment(\.widgetRenderingMode) private var widgetRenderingMode

    private let columns = 16

    var body: some View {
        HeatmapGrid(
            cells: HeatmapWidgetData.recentCells(from: entry.viewModel, count: columns * 7),
            maxMiles: entry.viewModel.maxMiles,
            today: entry.viewModel.today,
            columns: columns,
            cellGap: tileGap,
            containerCornerRadius: 24,
            gridPadding: gridPadding
        )
        .padding(gridPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var tileGap: CGFloat {
        widgetRenderingMode == .fullColor ? 5 : 4
    }

    private var gridPadding: CGFloat {
        widgetRenderingMode == .fullColor ? 8 : 7
    }
}
