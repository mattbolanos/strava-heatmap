import SwiftUI
import StravaHeatmapCore

struct LoginView: View {
    let onAuthenticated: () -> Void

    @State private var isLoading = false
    @State private var errorMessage: String?
    private let oauth = OAuthSessionCoordinator()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HeatmapPreview()
                .frame(maxWidth: 220)
                .padding(.bottom, 32)

            Text("Stratiles")
                .font(.largeTitle.bold())
                .padding(.bottom, 8)

            Text("Your Strava activity heatmap,\nright on your Home Screen.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.bottom, 32)

            Button {
                Task { await connectWithStrava() }
            } label: {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 22)
                } else {
                    Text("Connect with Strava")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 14)
            .foregroundStyle(.white)
            .background(Theme.stravaOrange, in: RoundedRectangle(cornerRadius: 12))
            .disabled(isLoading)

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
            }

   
        }
        .padding(24)
    }

    private func connectWithStrava() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let config = try StravaConfiguration.current()
            let authorizeURL = try makeAuthorizeURL(clientID: config.clientID)
            let callbackURL = try await oauth.authenticate(url: authorizeURL, callbackScheme: StravaConfiguration.callbackURLScheme)

            guard let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "code" })?
                .value else {
                throw LoginError.missingCode
            }

            _ = try await StravaAPIClient.shared.exchangeAuthorizationCode(code)
            onAuthenticated()
        } catch {
            await MainActor.run {
                errorMessage = "Unable to complete Strava login. Check your STRAVA_CLIENT_ID / STRAVA_CLIENT_SECRET Info.plist keys and try again."
            }
        }

        await MainActor.run {
            isLoading = false
        }
    }

    private func makeAuthorizeURL(clientID: String) throws -> URL {
        var components = URLComponents(string: "https://www.strava.com/oauth/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: StravaConfiguration.callbackURL),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "activity:read_all"),
            URLQueryItem(name: "approval_prompt", value: "auto"),
        ]

        guard let url = components.url else {
            throw LoginError.invalidAuthorizeURL
        }

        return url
    }
}

enum LoginError: Error {
    case invalidAuthorizeURL
    case missingCode
}
