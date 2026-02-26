import SwiftUI
import StratilesCore

struct StatsView: View {
    let selectedTypes: Set<ActivityType>
    let reloadToken: UUID

    @State private var viewModel = StatsViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Stats")
                .modifier(SubtitleModifier("Past 365 days"))
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task { await viewModel.refresh(selectedTypes: selectedTypes, force: true) }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
        }
        .task(id: reloadToken) {
            await viewModel.refresh(selectedTypes: selectedTypes)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadState {
        case .idle, .loading:
            ProgressView("Loading your stats…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .empty:
            ContentUnavailableView(
                "No activities in last 12 months",
                systemImage: "calendar.badge.exclamationmark",
                description: Text("Complete a Strava activity and pull to refresh.")
            )

        case let .failed(message):
            ContentUnavailableView(
                "Stats unavailable",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )

        case let .loaded(insights):
            ScrollView {
                VStack(spacing: 14) {
                    if let staleNotice = viewModel.staleNotice {
                        staleBanner(staleNotice)
                    }

                    StatsKPIHeader(insights: insights)
                    StatsCalendarHeatmap(insights: insights)
                    TrainingRhythmHeatmap(insights: insights)
                    WeeklyMilesChart(insights: insights)
                    PaceTrendChart(insights: insights)
                    EffortTimelineChart(insights: insights)
                    TopActivitiesCard(insights: insights)

                    Text("Stats based on your activities from past 365 days.")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .refreshable {
                await viewModel.refresh(selectedTypes: selectedTypes, force: true)
            }
        }
    }

    private func staleBanner(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "icloud.slash")
                .foregroundStyle(.yellow)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(.thinMaterial, in: .rect(cornerRadius: 12, style: .continuous))
    }
}

private struct SubtitleModifier: ViewModifier {
    let subtitle: String

    init(_ subtitle: String) {
        self.subtitle = subtitle
    }

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.navigationSubtitle(subtitle)
        } else {
            content
        }
    }
}
