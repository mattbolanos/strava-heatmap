import SwiftUI
import StravaHeatmapCore
import WidgetKit

struct HeatmapGrid: View {
    let cells: [HeatmapCell?]
    let maxMiles: Double
    let today: Date
    let columns: Int
    let cellGap: CGFloat
    var containerCornerRadius: CGFloat = 0
    var gridPadding: CGFloat = 0
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode

    private let rows = 7

    var body: some View {
        GeometryReader { proxy in
            let layout = GridLayout(
                size: proxy.size,
                columns: columns,
                rows: rows,
                gap: cellGap,
                containerCornerRadius: containerCornerRadius,
                gridPadding: gridPadding
            )

            if widgetRenderingMode == .fullColor {
                Canvas { context, _ in
                    drawCells(
                        in: context,
                        layout: layout,
                        filter: { _ in true },
                        color: fullColor(for:)
                    )
                }
            } else {
                ZStack {
                    Canvas { context, _ in
                        drawCells(
                            in: context,
                            layout: layout,
                            filter: isPrimaryAccentedCell(_:),
                            color: primaryAccentedColor(for:)
                        )
                    }

                    Canvas { context, _ in
                        drawCells(
                            in: context,
                            layout: layout,
                            filter: isAccentCell(_:),
                            color: accentColor(for:)
                        )
                    }
                    .widgetAccentable()
                }
            }
        }
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

    private func primaryAccentedColor(for cell: HeatmapCell?) -> Color {
        guard let cell else {
            return HeatmapWidgetStyle.vibrantEmptyTileColor
        }

        guard cell.date <= today else {
            return HeatmapWidgetStyle.vibrantFutureTileColor
        }

        return HeatmapWidgetStyle.vibrantEmptyTileColor
    }

    private func accentColor(for cell: HeatmapCell?) -> Color {
        guard let cell, cell.date <= today, cell.miles > 0 else {
            return .clear
        }

        let level = min(max(HeatmapBuilder.getLevel(miles: cell.miles, maxMiles: maxMiles), 1), 4)
        return HeatmapWidgetStyle.vibrantTileOpacityByLevel[level]
    }

    private func isAccentCell(_ cell: HeatmapCell?) -> Bool {
        guard let cell else {
            return false
        }
        return cell.date <= today && cell.miles > 0
    }

    private func isPrimaryAccentedCell(_ cell: HeatmapCell?) -> Bool {
        !isAccentCell(cell)
    }

    private func drawCells(
        in context: GraphicsContext,
        layout: GridLayout,
        filter: (HeatmapCell?) -> Bool,
        color: (HeatmapCell?) -> Color
    ) {
        let lastCol = columns - 1
        let lastRow = rows - 1
        let cr = layout.cornerRadius
        let outerCR = layout.outerCornerRadius

        for column in 0..<columns {
            for row in 0..<rows {
                let index = column * rows + row
                guard index < cells.count else { continue }

                let cell = cells[index]
                guard cell != nil else { continue }
                guard filter(cell) else { continue }

                let x = layout.origin.x + CGFloat(column) * (layout.cellSize + cellGap)
                let y = layout.origin.y + CGFloat(row) * (layout.cellSize + cellGap)
                let rect = CGRect(x: x, y: y, width: layout.cellSize, height: layout.cellSize)

                let path: Path
                if outerCR > cr {
                    if column == 0 && row == 0 {
                        path = Path(roundedRect: rect, cornerRadii: .init(topLeading: outerCR, bottomLeading: cr, bottomTrailing: cr, topTrailing: cr), style: .continuous)
                    } else if column == lastCol && row == 0 {
                        path = Path(roundedRect: rect, cornerRadii: .init(topLeading: cr, bottomLeading: cr, bottomTrailing: cr, topTrailing: outerCR), style: .continuous)
                    } else if column == 0 && row == lastRow {
                        path = Path(roundedRect: rect, cornerRadii: .init(topLeading: cr, bottomLeading: outerCR, bottomTrailing: cr, topTrailing: cr), style: .continuous)
                    } else if column == lastCol && row == lastRow {
                        path = Path(roundedRect: rect, cornerRadii: .init(topLeading: cr, bottomLeading: cr, bottomTrailing: outerCR, topTrailing: cr), style: .continuous)
                    } else {
                        path = Path(roundedRect: rect, cornerRadius: cr)
                    }
                } else {
                    path = Path(roundedRect: rect, cornerRadius: cr)
                }

                context.fill(path, with: .color(color(cell)))
            }
        }
    }

    private struct GridLayout {
        let cellSize: CGFloat
        let cornerRadius: CGFloat
        let outerCornerRadius: CGFloat
        let origin: CGPoint

        init(size: CGSize, columns: Int, rows: Int, gap: CGFloat, containerCornerRadius: CGFloat = 0, gridPadding: CGFloat = 0) {
            // Calculate the largest square cell that fits in both dimensions
            let maxCellWidth = (size.width - CGFloat(max(columns - 1, 0)) * gap) / CGFloat(columns)
            let maxCellHeight = (size.height - CGFloat(max(rows - 1, 0)) * gap) / CGFloat(rows)
            let cellSize = floor(min(maxCellWidth, maxCellHeight))

            let usedWidth = cellSize * CGFloat(columns) + CGFloat(max(columns - 1, 0)) * gap
            let usedHeight = cellSize * CGFloat(rows) + CGFloat(max(rows - 1, 0)) * gap

            self.cellSize = cellSize
            self.cornerRadius = min(max(cellSize * 0.15, 2), 4)
            self.outerCornerRadius = max(containerCornerRadius - gridPadding - (gap / 2), self.cornerRadius)
            self.origin = CGPoint(
                x: (size.width - usedWidth) / 2,
                y: (size.height - usedHeight) / 2
            )
        }
    }
}

enum HeatmapWidgetStyle {
    static let backgroundColor = Color(red: 0.02, green: 0.03, blue: 0.05)
    static let legacyBackgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.02, green: 0.02, blue: 0.03),
            Color(red: 0.01, green: 0.01, blue: 0.02)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
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
    static func recentCells(from viewModel: HeatmapViewModel, columns: Int) -> [HeatmapCell?] {
        guard columns > 0 else { return [] }

        // Take the last N weeks, preserving week structure (each week = Sun..Sat)
        let recentWeeks = viewModel.weeks.suffix(columns)
        let paddingCount = max(0, columns - recentWeeks.count)

        var cells: [HeatmapCell?] = []

        // Pad with nils for missing weeks at the start
        for _ in 0..<(paddingCount * 7) {
            cells.append(nil)
        }

        // Append each week's 7 days, nilling out future dates
        for week in recentWeeks {
            for cell in week.values {
                if cell.date > viewModel.today {
                    cells.append(nil)
                } else {
                    cells.append(cell)
                }
            }
        }

        return cells
    }
}
