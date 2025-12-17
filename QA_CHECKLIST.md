# THUNDRA — QA Checklist (iOS-first)

## Setup
- Run: `flutter pub get`
- iOS Simulator: `flutter run -d "iPhone 16"`
- Optional performance run: `flutter run -d "iPhone 16" --profile`
- Optional logs: `flutter run -d "iPhone 16" -v`

## Smoke (App Boot)
- App launches to the TabBar and stays responsive for 60s.
- Tabs switch without visual glitches: Live → Heatmap → Alerts → Stats.

## Live (Map + Filtering)
- Wait 10–20s, verify strikes appear and keep streaming (mock data).
- Change window: `1m / 5m / 15m / 60m` and confirm:
  - Count text updates: “Last {X} min · {N} strikes”.
  - Old strikes fade and eventually disappear.
- Map interactions:
  - Pan and pinch-zoom both directions (in/out).
  - `+ / -` buttons zoom in/out.
  - Location button recenters when permission is granted (if denied, no crash).

## Heatmap (Bins + Filters + Tap)
- Switch filter: `Today / 7 Days / 30 Days / All Time` and confirm bins update.
- Verify heat circles are visible at multiple zoom levels and remain stable while zooming.
- Tap a heat area:
  - A bottom card appears with “This area: {count} strikes”.
  - Close (x) hides the card.
- Empty state:
  - If no data in window, the empty overlay appears (no crash).

## Alerts (Trigger + Throttle + Quiet Hours)
- Enable Alerts:
  - Confirm the calm enable dialog shows.
  - Approve notification permission (if prompted).
  - Approve location permission.
- Set `Radius: 10km`, `Window: 10m`.
- Verify status card updates:
  - Monitoring ON/OFF
  - Location Granted/Denied
  - Quiet hours Active/Inactive
- Throttle:
  - After one alert fires, no new alert for ~5 minutes unless a meaningfully closer strike occurs.
- Quiet hours:
  - Enable quiet hours and set a range including “now”; confirm alerts do not fire.

## Stats (Charts + Filters)
- Switch filter: `Today / 7 Days / 30 Days / All Time`.
- Verify:
  - Summary cards update (Most active day/month + Total).
  - Charts render without overflow and remain readable in dark mode.
- Empty state:
  - If total is 0, the “No strikes yet…” card appears.

## Persistence (Across Restarts)
- Let the app run for ~1–2 minutes to accumulate strikes.
- Force quit the app (Simulator: swipe away) and relaunch.
- Verify:
  - Heatmap shows bins again without waiting for a long rebuild.
  - Stats totals are non-zero and consistent.
  - Alerts settings persist (enabled/radius/window/quiet hours).

## Performance / Stability (5–10 min)
- Spend 5–10 minutes switching tabs, zooming/panning, and changing filters.
- Confirm:
  - No crashes.
  - No “stuck” UI.
  - Map stays responsive (no runaway overlay growth).

## Assets (App Icon + Splash)
- App icon looks crisp at small size on the home screen.
- Splash screen is flat dark background with centered blue symbol (no text, no gradients).

