import SwiftUI

public enum HeatmapColors {
    public static let colorMixByLevel = [0.0, 0.50, 0.70, 0.85, 1.0]

    public static func tileColor(level: Int, colorScheme: ColorScheme) -> Color {
        let clamped = min(max(level, 0), 4)
        let mix = colorMixByLevel[clamped]
        let muted = colorScheme == .dark ? RGB(0.15, 0.15, 0.15) : RGB(0.90, 0.90, 0.90)
        let strava = RGB(252.0 / 255.0, 82.0 / 255.0, 0.0)

        let red = muted.r + (strava.r - muted.r) * mix
        let green = muted.g + (strava.g - muted.g) * mix
        let blue = muted.b + (strava.b - muted.b) * mix

        return Color(red: red, green: green, blue: blue)
    }

    private struct RGB {
        let r: Double
        let g: Double
        let b: Double

        init(_ r: Double, _ g: Double, _ b: Double) {
            self.r = r
            self.g = g
            self.b = b
        }
    }
}
