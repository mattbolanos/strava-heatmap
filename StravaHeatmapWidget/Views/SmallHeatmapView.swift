import SwiftUI
import StravaHeatmapCore
import WidgetKit

struct SmallHeatmapView: View {
    let entry: HeatmapEntry

    @Environment(\.widgetRenderingMode) private var widgetRenderingMode

    private let columns = 7

    var body: some View {
        HeatmapGrid(
            cells: HeatmapWidgetData.recentCells(from: entry.viewModel, count: columns * 7),
            maxMiles: entry.viewModel.maxMiles,
            today: entry.viewModel.today,
            columns: columns,
            cellGap: tileGap,
            containerCornerRadius: 28,
            gridPadding: gridPadding
        )
        .padding(gridPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var tileGap: CGFloat {
        widgetRenderingMode == .fullColor ? 4 : 3
    }

    private var gridPadding: CGFloat {
        widgetRenderingMode == .fullColor ? 16 : 15
    }
}
