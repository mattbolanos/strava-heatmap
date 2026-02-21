import SwiftUI
import StravaHeatmapCore

struct SmallHeatmapView: View {
    let entry: HeatmapEntry

    var body: some View {
        HeatmapGrid(
            cells: HeatmapWidgetData.recentCells(from: entry.viewModel, count: 49),
            maxMiles: entry.viewModel.maxMiles,
            today: entry.viewModel.today,
            columns: 7,
            rows: 7
        )
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
