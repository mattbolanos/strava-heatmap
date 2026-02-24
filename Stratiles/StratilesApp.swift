import SwiftUI

@main
struct StratilesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .tint(Theme.stravaOrange)
        }
    }
}
