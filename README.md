# Stratiles

Stratiles is an iOS widget that turns your Strava activity history into a GitHub-style heatmap. It helps you track training consistency at a glance from your Home Screen.

## What it does

- Connects to Strava using OAuth (`activity:read_all` scope)
- Builds calendar heatmaps from your activities
- Supports filtering by activity type (run, ride, swim, hiking, and more)
- Ships a Home Screen widget in multiple sizes
- Includes in-app stats views (weekly miles, pace trend, effort timeline, top activities)

## Project structure

- `Stratiles/` - iOS app target (SwiftUI screens + app shell)
- `StratilesWidget/` - WidgetKit extension target
- `StratilesCore/` - shared models, API client, caching, heatmap logic
- `worker/` - Cloudflare Worker used as OAuth token exchange proxy
- `docs/` - privacy policy and App Store metadata

## Tech stack

- SwiftUI + WidgetKit (iOS 17+)
- Shared core module for business/data logic
- Strava API for activity data
- Cloudflare Workers for secure token exchange

## Getting started

### iOS app

1. Open `Stratiles.xcodeproj` in Xcode.
2. Select the `Stratiles` scheme.
3. Build and run on an iOS 17+ simulator or device.
4. Sign in with Strava from the login screen.

Notes:

- The app reads `STRAVA_CLIENT_ID` from `Stratiles/Info.plist`.
- OAuth callback URL is `stratiles://localhost/callback`.

### OAuth worker (optional for local/prod auth changes)

The app exchanges Strava auth codes through a Cloudflare Worker.

1. Go to the worker folder:
   - `cd worker`
2. Install dependencies:
   - `bun install`
3. Set Cloudflare secrets:
   - `wrangler secret put STRAVA_CLIENT_ID`
   - `wrangler secret put STRAVA_CLIENT_SECRET`
4. Run locally:
   - `bun run dev`
5. Deploy:
   - `bun run deploy`

If you deploy your own worker URL, update `authWorkerBaseURL` in `StratilesCore/Support/SharedConstants.swift`.

## Contributing

Contributions are welcome. For non-trivial changes, open an issue first to align on approach.

1. Fork and create a branch for your work.
2. Keep changes focused and small where possible.
3. Build the app and widget targets before opening a PR.
4. Include clear PR notes:
   - What changed
   - Why it changed
   - How you tested it
5. Link related issues in the PR description.
