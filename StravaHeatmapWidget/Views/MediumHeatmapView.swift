import SwiftUI
import StravaHeatmapCore

struct MediumHeatmapView: View {
    let entry: HeatmapEntry

    var body: some View {
        HeatmapGrid(
            cells: HeatmapWidgetData.recentCells(from: entry.viewModel, count: 36),
            maxMiles: entry.viewModel.maxMiles,
            today: entry.viewModel.today,
            columns: 9,
            rows: 4
        )
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
