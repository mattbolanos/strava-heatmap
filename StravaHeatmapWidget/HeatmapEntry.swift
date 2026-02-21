import Foundation
import WidgetKit
import StravaHeatmapCore

struct HeatmapEntry: TimelineEntry {
    let date: Date
    let configuration: SelectActivityTypesIntent
    let viewModel: HeatmapViewModel
    let selectedTypes: [ActivityType]
    let isPlaceholder: Bool

    static func placeholder() -> HeatmapEntry {
        let days = (0..<150).map { offset -> HeatmapDay in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            return HeatmapDay(
                date: HeatmapBuilder.toDateKey(date),
                miles: Double((offset % 8)) * 0.9,
                activityCount: offset.isMultiple(of: 3) ? 0 : 1,
                distanceMeters: Double((offset % 8)) * 0.9 * 1_609.344
            )
        }
        let view = HeatmapBuilder.buildHeatmapView(heatmap: days, weeksToShow: 52)
        return HeatmapEntry(
            date: Date(),
            configuration: SelectActivityTypesIntent(),
            viewModel: view,
            selectedTypes: [.run],
            isPlaceholder: true
        )
    }
}
