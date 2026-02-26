import SwiftUI
import StratilesCore

struct SignedInRootView: View {
    let onSignedOut: () -> Void

    @State private var selectedTab: SignedInTab = .stats
    @State private var selectedTypes = SharedActivityTypeSettings.loadSelectedTypes()
    @State private var statsReloadToken = UUID()

    var body: some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            SignedInRootTabsModern(
                selectedTab: $selectedTab,
                selectedTypes: $selectedTypes,
                statsReloadToken: $statsReloadToken,
                onSignedOut: onSignedOut
            )
        } else {
            TabView(selection: $selectedTab) {
                StatsView(selectedTypes: selectedTypes, reloadToken: statsReloadToken)
                    .tabItem {
                        Label("Stats", systemImage: "shoeprints.fill")
                    }
                    .tag(SignedInTab.stats)

                SettingsView(
                    onSignedOut: onSignedOut,
                    onActivityTypesChanged: handleActivityTypesChanged(_:)
                )
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(SignedInTab.settings)
            }
        }
    }

    private func handleActivityTypesChanged(_ types: Set<ActivityType>) {
        selectedTypes = types
        statsReloadToken = UUID()
    }
}

private enum SignedInTab: Hashable {
    case stats
    case settings
}

@available(iOS 18.0, macOS 15.0, *)
private struct SignedInRootTabsModern: View {
    @Binding var selectedTab: SignedInTab
    @Binding var selectedTypes: Set<ActivityType>
    @Binding var statsReloadToken: UUID

    let onSignedOut: () -> Void

    @AppStorage("signedInTabCustomization") private var tabCustomization = TabViewCustomization()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Stats", systemImage: "shoeprints.fill", value: SignedInTab.stats) {
                StatsView(selectedTypes: selectedTypes, reloadToken: statsReloadToken)
            }

            TabSection("Account") {
                Tab("Settings", systemImage: "gearshape", value: SignedInTab.settings) {
                    SettingsView(
                        onSignedOut: onSignedOut,
                        onActivityTypesChanged: handleActivityTypesChanged(_:)
                    )
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($tabCustomization)
    }

    private func handleActivityTypesChanged(_ types: Set<ActivityType>) {
        selectedTypes = types
        statsReloadToken = UUID()
    }
}
