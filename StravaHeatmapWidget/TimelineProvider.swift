import Foundation
import WidgetKit
import StravaHeatmapCore

struct HeatmapTimelineProvider: AppIntentTimelineProvider {
    private let cacheFreshness: TimeInterval = 3_600

    func placeholder(in context: Context) -> HeatmapEntry {
        HeatmapEntry.placeholder()
    }

    func snapshot(for configuration: SelectActivityTypesIntent, in context: Context) async -> HeatmapEntry {
        let selectedTypes = resolvedTypes(from: configuration)

        if let cached = await ActivityCache.shared.read(selectedTypes: selectedTypes) {
            let viewModel = HeatmapBuilder.buildHeatmapView(heatmap: cached.heatmapDays, weeksToShow: 52)
            return HeatmapEntry(
                date: Date(),
                configuration: configuration,
                viewModel: viewModel,
                selectedTypes: Array(selectedTypes),
                isPlaceholder: false
            )
        }

        return HeatmapEntry.placeholder()
    }

    func timeline(for configuration: SelectActivityTypesIntent, in context: Context) async -> Timeline<HeatmapEntry> {
        let selectedTypes = resolvedTypes(from: configuration)

        do {
            let heatmapDays = try await loadDays(selectedTypes: selectedTypes)
            let viewModel = HeatmapBuilder.buildHeatmapView(heatmap: heatmapDays, weeksToShow: 52)
            let entry = HeatmapEntry(
                date: Date(),
                configuration: configuration,
                viewModel: viewModel,
                selectedTypes: Array(selectedTypes),
                isPlaceholder: false
            )
            return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(4 * 3_600)))
        } catch {
            if let cached = await ActivityCache.shared.read(selectedTypes: selectedTypes) {
                let viewModel = HeatmapBuilder.buildHeatmapView(heatmap: cached.heatmapDays, weeksToShow: 52)
                let entry = HeatmapEntry(
                    date: Date(),
                    configuration: configuration,
                    viewModel: viewModel,
                    selectedTypes: Array(selectedTypes),
                    isPlaceholder: false
                )
                return Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(15 * 60)))
            }

            let placeholder = HeatmapEntry.placeholder()
            return Timeline(entries: [placeholder], policy: .after(Date().addingTimeInterval(15 * 60)))
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

    private func resolvedTypes(from configuration: SelectActivityTypesIntent) -> Set<ActivityType> {
        let fromIntent = Set(configuration.activityTypes)
        if !fromIntent.isEmpty {
            return fromIntent
        }
        return SharedActivityTypeSettings.loadSelectedTypes()
    }
}
