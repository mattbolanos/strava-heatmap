import SwiftUI
import StravaHeatmapCore
import WidgetKit

struct HeatmapGrid: View {
    let cells: [HeatmapCell?]
    let maxMiles: Double
    let today: Date
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode

    var body: some View {
        GeometryReader { proxy in
            let layout = GridLayout(size: proxy.size, columns: columns, rows: rows)

            Canvas { context, _ in
                let clippingRect = CGRect(
                    x: layout.origin.x,
                    y: layout.origin.y,
                    width: layout.usedWidth,
                    height: layout.usedHeight
                )
                let clippingPath = Path(
                    roundedRect: clippingRect,
                    cornerRadius: layout.outerCornerRadius,
                    style: .continuous
                )
                context.clip(to: clippingPath)

                for row in 0..<rows {
                    for column in 0..<columns {
                        let index = row * columns + column
                        guard index < cells.count else { continue }

                        let mirroredColumn = columns - 1 - column
                        let x = layout.origin.x + CGFloat(mirroredColumn) * (layout.tileSize + layout.gap)
                        let y = layout.origin.y + CGFloat(row) * (layout.tileSize + layout.gap)
                        let rect = CGRect(x: x, y: y, width: layout.tileSize, height: layout.tileSize)
                        let path = Path(roundedRect: rect, cornerRadius: layout.cornerRadius)
                        context.fill(path, with: .color(color(for: cells[index])))
                    }
                }
            }
        }
    }

    private let columns: Int
    private let rows: Int

    init(
        cells: [HeatmapCell?],
        maxMiles: Double,
        today: Date,
        columns: Int,
        rows: Int
    ) {
        self.cells = cells
        self.maxMiles = maxMiles
        self.today = today
        self.columns = max(columns, 1)
        self.rows = max(rows, 1)
    }

    private func color(for cell: HeatmapCell?) -> Color {
        if widgetRenderingMode == .fullColor {
            return fullColor(for: cell)
        }

        return monochromeColor(for: cell)
    }

    private func fullColor(for cell: HeatmapCell?) -> Color {
        guard let cell else {
            return HeatmapWidgetStyle.emptyTileColor
        }

        guard cell.date <= today else {
            return HeatmapWidgetStyle.emptyTileColor.opacity(0.7)
        }

        let level = HeatmapBuilder.getLevel(miles: cell.miles, maxMiles: maxMiles)
        return HeatmapColors.tileColor(level: level, colorScheme: .dark)
    }

    private func monochromeColor(for cell: HeatmapCell?) -> Color {
        guard let cell else {
            return HeatmapWidgetStyle.vibrantEmptyTileColor
        }

        guard cell.date <= today else {
            return HeatmapWidgetStyle.vibrantFutureTileColor
        }

        let level = min(max(HeatmapBuilder.getLevel(miles: cell.miles, maxMiles: maxMiles), 0), 4)
        return HeatmapWidgetStyle.vibrantTileOpacityByLevel[level]
    }

    private struct GridLayout {
        let tileSize: CGFloat
        let gap: CGFloat
        let cornerRadius: CGFloat
        let outerCornerRadius: CGFloat
        let usedWidth: CGFloat
        let usedHeight: CGFloat
        let origin: CGPoint

        init(size: CGSize, columns: Int, rows: Int) {
            let shortSide = min(size.width, size.height)
            let gap = min(max(shortSide * 0.02, 1.5), 4)

            let tileWidth = (size.width - CGFloat(max(columns - 1, 0)) * gap) / CGFloat(max(columns, 1))
            let tileHeight = (size.height - CGFloat(max(rows - 1, 0)) * gap) / CGFloat(max(rows, 1))
            let tileSize = max(1, floor(min(tileWidth, tileHeight)))

            let usedWidth = tileSize * CGFloat(columns) + CGFloat(max(columns - 1, 0)) * gap
            let usedHeight = tileSize * CGFloat(rows) + CGFloat(max(rows - 1, 0)) * gap

            self.tileSize = tileSize
            self.gap = gap
            self.cornerRadius = min(max(tileSize * 0.24, 3), 8)
            self.outerCornerRadius = min(max(tileSize * 0.55, 8), 16)
            self.usedWidth = usedWidth
            self.usedHeight = usedHeight
            self.origin = CGPoint(
                x: (size.width - usedWidth) / 2,
                y: (size.height - usedHeight) / 2
            )
        }
    }
}

enum HeatmapWidgetStyle {
    static let backgroundColor = Color(red: 0.04, green: 0.05, blue: 0.07)
    static let emptyTileColor = HeatmapColors.tileColor(level: 0, colorScheme: .dark)
    static let vibrantEmptyTileColor = Color.primary.opacity(0.22)
    static let vibrantFutureTileColor = Color.primary.opacity(0.16)
    static let vibrantTileOpacityByLevel: [Color] = [
        Color.primary.opacity(0.22),
        Color.primary.opacity(0.35),
        Color.primary.opacity(0.5),
        Color.primary.opacity(0.68),
        Color.primary.opacity(0.85)
    ]
}

enum HeatmapWidgetData {
    static func recentCells(from viewModel: HeatmapViewModel, count: Int) -> [HeatmapCell?] {
        guard count > 0 else {
            return []
        }

        let completedDays = viewModel.weeks
            .flatMap(\.values)
            .filter { $0.date <= viewModel.today }
            .sorted { $0.date < $1.date }

        let visible = Array(completedDays.suffix(count))
        let missing = max(0, count - visible.count)
        return Array(repeating: nil, count: missing) + visible.map(Optional.some)
    }
}
