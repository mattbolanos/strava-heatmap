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
                .tint(Theme.stravaOrange)

                Section {
                    WidgetInstructionRow(step: 1, icon: "plus.app", text: "Long-press your Home Screen")
                    WidgetInstructionRow(step: 2, icon: "hand.tap", text: "Tap Add Widget")
                    WidgetInstructionRow(step: 3, icon: "magnifyingglass", text: "Search for \"Stratiles\"")
                    WidgetInstructionRow(step: 4, icon: "checkmark.circle", text: "Add the widget you want!")
                } header: {
                    Text("Add to Home Screen")
                } footer: {
                    Text("Tip: Long-press the widget and choose \"Edit Widget\" to change activity types directly.")
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
                } header: {
                    Text("Account")
                }
            }
            .navigationTitle("Stratiles")
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

private struct WidgetInstructionRow: View {
    let step: Int
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.stravaOrange.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.stravaOrange)
            }

            Text("\(step). \(text)")
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}
