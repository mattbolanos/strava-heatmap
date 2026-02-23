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
                ForEach(ActivityType.grouped(), id: \.category) { group in
                    Section {
                        ForEach(group.types, id: \.self) { type in
                            Toggle(type.displayName, isOn: binding(for: type))
                        }
                    } header: {
                        if #available(iOS 26.0, *) {
                            Label(group.category.rawValue, systemImage: group.category.icon)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.stravaOrange)
                                .textCase(nil)
                                .labelStyle(.titleAndIcon)
                                .labelIconToTitleSpacing(8)
                        } else {
                            Label(group.category.rawValue, systemImage: group.category.icon)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.stravaOrange)
                                .textCase(nil)
                                .labelStyle(.titleAndIcon)
                        }
                    }
                }
                .tint(Theme.stravaOrange)

                Section {
                    WidgetInstructionRow(step: 1, icon: "plus.app", text: "Long-press your Home Screen")
                    WidgetInstructionRow(step: 2, icon: "hand.tap", text: "Tap Add Widget")
                    WidgetInstructionRow(step: 3, icon: "magnifyingglass", text: "Search for \"Stratiles\"")
                    WidgetInstructionRow(step: 4, icon: "checkmark.circle", text: "Add the widget you want!")
                } header: {
                    if #available(iOS 26.0, *) {
                        Label("Add to Home Screen", systemImage: "square.grid.2x2")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.stravaOrange)
                            .textCase(nil)
                            .labelStyle(.titleAndIcon)
                            .labelIconToTitleSpacing(8)
                    } else {
                        Label("Add to Home Screen", systemImage: "square.grid.2x2")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.stravaOrange)
                            .textCase(nil)
                            .labelStyle(.titleOnly)
                    }
                } footer: {
                    Text("Long-press the widget and choose \"Edit Widget\" to change activity types directly from there.")
                }

                Section {
                    Button(role: .destructive) {
                        Task { await signOut() }
                    } label: {
                        HStack {
                            if isSigningOut {
                                ProgressView()
                            } else {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        }
                    }
                    .disabled(isSigningOut)
                }
            }
            .navigationTitle("Stratiles")
        }
        .onChange(of: selectedTypes) { _, newValue in
            let nonEmpty = newValue.isEmpty ? ActivityType.defaultSelected : newValue
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
                    .fill(Theme.subtleOrange)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.stravaOrange)
            }

            Text("\(step). \(text)")
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}
