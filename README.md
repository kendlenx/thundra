# THUNDRA (Flutter, iOS‑first)
Global lightning tracker — premium dark UI with live map, heatmap, alerts, and stats.

## Quickstart (iOS Simulator)
- `flutter pub get`
- `flutter run -d "iPhone 16"`  
  Optional Google Maps (requires your API key): `flutter run --dart-define=THUNDRA_USE_GOOGLE_MAPS=true`
- CocoaPods hiccup? `cd ios && pod install && cd ..`

## Features
- **Live Map:** Dark base map, fading strike dots, 1/5/15/60m window, zoom buttons + pinch.
- **Heatmap:** Grid bin aggregation, Today/7/30/All filters, tap to inspect bin.
- **Alerts:** Radius (5/10/25 km), window (10/30 m), quiet hours, local notification (best effort), in-app banner.
- **Stats:** Daily (14d) line + Monthly (12m) bars, most active day/month, totals with window filters.
- **Persistence:** Drift (SQLite) stores strikes + alert settings; 30-day purge keeps the DB lean.
- **Mock Feed:** `LightningDataSource` interface with `MockLightningDataSource` for offline dev; placeholder network DS stubbed for later.
- **Design:** Midnight navy background `#0B0F1A`, electric blue accent `#3ABEFF`, iOS-first tab navigation, premium dark splash/icon.

## Architecture
- `lib/data/` — datasources, Drift DB, repositories, ingestion.
- `lib/domain/` — models/entities, services, use-cases, repository contracts.
- `lib/presentation/` — screens, widgets, Riverpod state, theming.

## Config & Assets
- Splash config: `flutter_native_splash.yaml` (uses `assets/splash/splash_logo.png`).
- App icon set: `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (all required sizes).
- Dark map style for Google Maps: `lib/presentation/live/google_dark_map_style.dart`.

## Running Tests
- `flutter test`

## Release Notes / Store Prep
- iOS permissions: `NSLocationWhenInUseUsageDescription` (calm copy). Local notifications are requested in-app (no extra plist key).
- Data retention: auto-purge >30 days (see `strikeRetentionProvider`).
- For App Store/TestFlight: build a release IPA via `flutter build ipa --release` (set signing/team in Xcode if needed).
- Map provider: defaults to free dark tiles; only enable Google Maps if you supply a key.

## QA
- Manual checklist: `QA_CHECKLIST.md` (5–10 min tab walk-through + persistence + alerts/quiet-hours checks).
