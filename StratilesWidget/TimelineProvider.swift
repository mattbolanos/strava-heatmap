import Foundation
import WidgetKit
import StratilesCore

struct HeatmapTimelineProvider: TimelineProvider {
    private let cacheFreshness: TimeInterval = 3_600

    func placeholder(in context: Context) -> HeatmapEntry {
        HeatmapEntry.placeholder()
    }

    func getSnapshot(in context: Context, completion: @escaping (HeatmapEntry) -> Void) {
        let selectedTypes = SharedActivityTypeSettings.loadSelectedTypes()

        Task {
            if let cached = await ActivityCache.shared.read(selectedTypes: selectedTypes) {
                let viewModel = HeatmapBuilder.buildHeatmapView(heatmap: cached.heatmapDays, weeksToShow: 52)
                completion(HeatmapEntry(
                    date: Date(),
                    viewModel: viewModel,
                    selectedTypes: Array(selectedTypes),
                    isPlaceholder: false
                ))
            } else {
                completion(HeatmapEntry.placeholder())
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HeatmapEntry>) -> Void) {
        let selectedTypes = SharedActivityTypeSettings.loadSelectedTypes()

        Task {
            do {
                let heatmapDays = try await loadDays(selectedTypes: selectedTypes)
                let viewModel = HeatmapBuilder.buildHeatmapView(heatmap: heatmapDays, weeksToShow: 52)
                let entry = HeatmapEntry(
                    date: Date(),
                    viewModel: viewModel,
                    selectedTypes: Array(selectedTypes),
                    isPlaceholder: false
                )
                completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(4 * 3_600))))
            } catch {
                if let cached = await ActivityCache.shared.read(selectedTypes: selectedTypes) {
                    let viewModel = HeatmapBuilder.buildHeatmapView(heatmap: cached.heatmapDays, weeksToShow: 52)
                    let entry = HeatmapEntry(
                        date: Date(),
                        viewModel: viewModel,
                        selectedTypes: Array(selectedTypes),
                        isPlaceholder: false
                    )
                    completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(15 * 60))))
                } else {
                    let placeholder = HeatmapEntry.placeholder()
                    completion(Timeline(entries: [placeholder], policy: .after(Date().addingTimeInterval(15 * 60))))
                }
            }
        }
    }

    private func loadDays(selectedTypes: Set<ActivityType>) async throws -> [HeatmapDay] {
        if let cached = await ActivityCache.shared.read(selectedTypes: selectedTypes), cached.isFresh(maxAge: cacheFreshness) {
            return cached.heatmapDays
        }

        let afterDate = Calendar.current.date(byAdding: .day, value: -366, to: Date()) ?? Date()
        let fresh = try await StravaAPIClient.shared.fetchActivities(selectedTypes: selectedTypes, after: afterDate)
        await ActivityCache.shared.write(heatmapDays: fresh, selectedTypes: selectedTypes)
        return fresh
    }
}
