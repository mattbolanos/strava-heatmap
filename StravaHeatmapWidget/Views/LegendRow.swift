import SwiftUI
import StravaHeatmapCore

struct LegendRow: View {
    let tileSize: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 4) {
            Text("Less")
                .foregroundStyle(.secondary)

            ForEach(0...4, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(HeatmapColors.tileColor(level: level, colorScheme: colorScheme))
                    .frame(width: tileSize, height: tileSize)
            }

            Text("More")
                .foregroundStyle(.secondary)
        }
        .font(.caption2)
    }
}
