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
                            Task {
                                await viewModel.refresh(selectedTypes: selectedTypes, force: true)
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.isRefreshing)
                        .disabled(viewModel.isRefreshing)
                    }
                }
        }
        .sensoryFeedback(.success, trigger: viewModel.refreshSuccessToken)
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
            ContentUnavailableView {
                Label("Stats unavailable", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") {
                    Task { await viewModel.refresh(selectedTypes: selectedTypes, force: true) }
                }
                .buttonStyle(.borderedProminent)
            }

        case let .loaded(insights):
            ScrollView {
                VStack(spacing: 0) {
                    StatsKPIHeader(insights: insights)

                    VStack(spacing: 14) {
                        sectionLabel("FREQUENCY")
                        StatsCalendarHeatmap(insights: insights)
                        TrainingRhythmHeatmap(insights: insights)
                    }
                    .padding(.top, 20)

                    VStack(spacing: 14) {
                        sectionLabel("TRENDS")
                        WeeklyMilesChart(insights: insights)
                        PaceTrendChart(insights: insights)
                        EffortTimelineChart(insights: insights)
                    }
                    .padding(.top, 20)

                    VStack(spacing: 14) {
                        sectionLabel("HIGHLIGHTS")
                        TopActivitiesCard(insights: insights)
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .refreshable {
                await viewModel.refresh(selectedTypes: selectedTypes, force: true)
            }
        }
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 2)
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
