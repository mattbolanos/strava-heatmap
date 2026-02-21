import SwiftUI
import StravaHeatmapCore

struct ContentView: View {
    @State private var authState: AuthState = .loading

    var body: some View {
        Group {
            switch authState {
            case .loading:
                ProgressView("Checking Strava account…")
            case .signedOut:
                LoginView {
                    Task { await refreshAuthState() }
                }
            case .signedIn:
                SettingsView {
                    Task { await refreshAuthState() }
                }
            }
        }
        .task {
            await refreshAuthState()
        }
    }

    private func refreshAuthState() async {
        let signedIn = await TokenManager.shared.hasRefreshToken()
        await MainActor.run {
            authState = signedIn ? .signedIn : .signedOut
        }
    }

    private enum AuthState {
        case loading
        case signedOut
        case signedIn
    }
}

#Preview {
    ContentView()
}
