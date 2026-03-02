# App Store Metadata

## Name

Stratiles

## Subtitle

Strava Activity Heatmap Widget

## Description

Turn your Strava activities into a beautiful heatmap widget for your Home Screen.

Stratiles reads your Strava activity data and renders it as a GitHub-style contribution heatmap right on your iPhone. See your training consistency at a glance without opening an app.

**Widget**

- Home Screen heatmap widget showing your activity history
- Supports running, cycling, swimming, hiking, and 20+ activity types
- Filter by the activity types you care about
- Multiple widget sizes (small, medium, large)

**Stats (past 365 days)**

- Summary: peak training time, peak day, total activities, distance, moving hours, elevation gain, kudos
- Miles-per-day heatmap and training rhythm (when you train by day and time)
- Weekly miles chart with consistency metrics
- Pace trend with rolling average, filterable by activity type
- Weekly effort (suffer score) timeline
- Top activities ranked by distance, elevation, or kudos

**Privacy-first**

- All data stays on your device
- No ads, no tracking, no accounts

Connect your Strava account to get started. A free Strava account is all you need.

## Keywords

strava, heatmap, widget, running, cycling, activity, fitness, tracker, calendar, training

## Category

Sports

## Review Notes

Stratiles uses Strava OAuth to authenticate users. To test:

1. You will need a free Strava account (https://www.strava.com/register)
2. Tap "Connect with Strava" to authorize the app
3. After authorization, activity data loads and the heatmap widget becomes available

Technical notes:

- The Strava client_secret is not in the app binary — token exchange is handled by a server-side proxy (Cloudflare Worker)
- The app only uses the activity:read_all OAuth scope
- All data is stored locally on-device via Keychain (tokens) and App Group shared container (activity cache)

## Privacy Nutrition Label

**Data Not Collected** — Stratiles does not collect any data. All activity data retrieved from Strava is stored locally on the user's device and is never transmitted to any server.
