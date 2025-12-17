# THUNDRA QA Checklist (Practical)

## Live (Points + Filters)
- Launch app on iOS Simulator, open **Live** tab.
- Confirm dark map loads and panning/zooming is smooth.
- Wait ~10–15 seconds: confirm new strikes appear as blue dots.
- Verify fading:
  - Switch to **1m** and observe that older dots disappear quickly.
  - Switch to **60m** and confirm more dots are retained.
- Verify overlay cap behavior:
  - Leave app running a few minutes; ensure performance stays stable and dots don’t explode in count (should cap).
- Empty state:
  - Switch to **1m** immediately after cold start and confirm “No strikes in this window” can appear.

## Heatmap (Bins + Filters + Tap)
- Open **Heatmap** tab.
- Confirm dark map loads and circles indicate density (blue only).
- Change filters: **Today / 7 Days / 30 Days / All Time**
  - Verify the heat overlay updates within ~1s.
  - Verify a light haptic occurs on each filter change.
- Tap on a visible bin:
  - Confirm bottom card appears showing “This area: {count} strikes”.
  - Confirm card window label matches the selected filter.
- Empty state:
  - If there is no data yet, confirm the “No strikes for this window” overlay is shown.

## Alerts (Trigger + Throttle + Quiet Hours)
- Open **Alerts** tab.
- Enable alerts:
  - Confirm calm permission dialog appears.
  - Grant location permission (When In Use).
  - Grant notification permission (iOS prompt).
- Set **Radius: 10km**, **Window: 10m**.
- Trigger test:
  - Tap the location button on Live once to set a “focus” for mock strikes.
  - Keep app running; within ~30–90 seconds you should see:
    - In-app banner: “Lightning detected within 10 km. Stay aware.”
    - Local notification (if allowed).
- Throttle:
  - After a banner fires, confirm it does not spam repeatedly (cooldown ~5 minutes unless a closer strike occurs).
- Quiet hours:
  - Enable quiet hours and set the current time to be inside the quiet window.
  - Confirm status shows Quiet hours “Active” and no banner/notification fires even if nearby strikes occur.
- Denied permissions:
  - Deny location permission and enable alerts.
  - Confirm status shows Location “Denied” and alerts do not fire.

## Persistence (DB)
- Run app 1–2 minutes to accumulate strikes.
- Force close the app (Simulator: swipe away).
- Relaunch:
  - Open **Heatmap** and **Stats** and confirm historical data persists.
  - Open **Alerts** and confirm settings persist (enabled/radius/window/quiet hours).

