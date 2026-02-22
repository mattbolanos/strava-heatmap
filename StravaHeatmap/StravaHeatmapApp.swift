import SwiftUI

@main
struct StravaHeatmapApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .tint(Theme.stravaOrange)
        }
    }
}
