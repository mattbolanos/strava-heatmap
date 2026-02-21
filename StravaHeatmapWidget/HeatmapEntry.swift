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
        // Seeded RNG for a natural-looking but deterministic pattern
        var seed: UInt64 = 0xDEAD_BEEF
        func nextRandom() -> Double {
            seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return Double((seed >> 33) & 0x7FFF_FFFF) / Double(0x7FFF_FFFF)
        }

        let days = (0..<150).map { offset -> HeatmapDay in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let r = nextRandom()
            // ~35% rest days, remaining days get varied distances
            let miles = r < 0.35 ? 0.0 : r * 7.0
            let count = miles > 0 ? 1 : 0
            return HeatmapDay(
                date: HeatmapBuilder.toDateKey(date),
                miles: miles,
                activityCount: count,
                distanceMeters: miles * 1_609.344
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
