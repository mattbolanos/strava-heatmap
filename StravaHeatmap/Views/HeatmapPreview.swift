import SwiftUI
import StravaHeatmapCore

struct HeatmapPreview: View {
    private let columns = 7
    private let rows = 7

    private let pattern: [[Int]] = [
        [0, 1, 0, 2, 0, 1, 0],
        [1, 3, 2, 0, 1, 2, 1],
        [0, 2, 4, 3, 2, 0, 0],
        [2, 0, 3, 4, 3, 1, 2],
        [0, 1, 2, 3, 4, 2, 0],
        [1, 2, 0, 1, 2, 3, 1],
        [0, 0, 1, 0, 1, 0, 0],
    ]

    var body: some View {
        Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            ForEach(0..<rows, id: \.self) { row in
                GridRow {
                    ForEach(0..<columns, id: \.self) { col in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(HeatmapColors.tileColor(level: pattern[row][col], colorScheme: .dark))
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }
}
