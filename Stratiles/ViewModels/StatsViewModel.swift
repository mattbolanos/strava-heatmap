import Foundation
import Observation
import StratilesCore

@MainActor
@Observable
final class StatsViewModel {
    enum LoadState {
        case idle
        case loading
        case loaded(ActivityInsights)
        case empty
        case failed(String)
    }

    private let cacheFreshness: TimeInterval = 3_600
    private let windowDays = 366

    enum RefreshNotice: Equatable {
        case updating
        case offline
    }

    var loadState: LoadState = .idle
    var refreshNotice: RefreshNotice?
    private(set) var refreshSuccessToken: UUID?

    var isRefreshing: Bool { refreshNotice == .updating }

    func refresh(selectedTypes: Set<ActivityType>, force: Bool = false) async {
        let normalizedTypes = selectedTypes.isEmpty ? ActivityType.defaultSelected : selectedTypes
        let windowEnd = Date()

        let cached = await ActivityCache.shared.read(selectedTypes: normalizedTypes)
        var showingCachedData = false

        if let cached {
            if let activities = cached.activities, !activities.isEmpty {
                let cachedInsights = ActivityInsightsBuilder.build(
                    activities: activities,
                    windowEnd: windowEnd,
                    windowDays: windowDays
                )
                loadState = cachedInsights.totalActivities == 0 ? .empty : .loaded(cachedInsights)
                showingCachedData = true

                if cached.isFresh(maxAge: cacheFreshness), !force {
                    refreshNotice = nil
                    return
                }

                refreshNotice = .updating
            } else if !cached.heatmapDays.isEmpty {
                let partialInsights = ActivityInsightsBuilder.buildPartial(
                    heatmapDays: cached.heatmapDays,
                    windowEnd: windowEnd,
                    windowDays: windowDays
                )
                loadState = partialInsights.totalActivities == 0 ? .empty : .loaded(partialInsights)
                refreshNotice = .updating
                showingCachedData = true
            }
        }

        if !showingCachedData {
            loadState = .loading
            refreshNotice = nil
        }

        do {
            let afterDate = Calendar.current.date(byAdding: .day, value: -windowDays, to: windowEnd) ?? windowEnd
            let activities = try await StravaAPIClient.shared.fetchRawActivities(
                selectedTypes: normalizedTypes,
                after: afterDate
            )
            let insights = ActivityInsightsBuilder.build(
                activities: activities,
                windowEnd: windowEnd,
                windowDays: windowDays
            )

            await ActivityCache.shared.write(
                heatmapDays: insights.heatmapDays,
                selectedTypes: normalizedTypes,
                activities: activities
            )

            refreshSuccessToken = UUID()
            refreshNotice = nil
            loadState = insights.totalActivities == 0 ? .empty : .loaded(insights)
        } catch {
            if showingCachedData {
                refreshNotice = .offline
                return
            }

            loadState = .failed("Unable to load stats right now. Please try again.")
        }
    }
}
