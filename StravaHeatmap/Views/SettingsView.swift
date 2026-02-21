import SwiftUI
import WidgetKit
import StravaHeatmapCore

struct SettingsView: View {
    let onSignedOut: () -> Void

    @State private var selectedTypes = SharedActivityTypeSettings.loadSelectedTypes()
    @State private var isSigningOut = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Activity Types") {
                    ForEach(ActivityType.allCases, id: \.self) { type in
                        Toggle(type.displayName, isOn: binding(for: type))
                    }
                }

                Section {
                    Button(role: .destructive) {
                        Task { await signOut() }
                    } label: {
                        if isSigningOut {
                            ProgressView()
                        } else {
                            Text("Sign Out")
                        }
                    }
                    .disabled(isSigningOut)
                }
            }
            .navigationTitle("Strava Heatmap")
        }
        .onChange(of: selectedTypes) { _, newValue in
            let nonEmpty = newValue.isEmpty ? Set([ActivityType.run]) : newValue
            selectedTypes = nonEmpty
            SharedActivityTypeSettings.saveSelectedTypes(nonEmpty)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func binding(for type: ActivityType) -> Binding<Bool> {
        Binding(
            get: { selectedTypes.contains(type) },
            set: { isOn in
                if isOn {
                    selectedTypes.insert(type)
                } else {
                    selectedTypes.remove(type)
                }
            }
        )
    }

    private func signOut() async {
        await MainActor.run { isSigningOut = true }
        await TokenManager.shared.clearToken()
        await ActivityCache.shared.clear()
        WidgetCenter.shared.reloadAllTimelines()
        await MainActor.run {
            isSigningOut = false
            onSignedOut()
        }
    }
}
