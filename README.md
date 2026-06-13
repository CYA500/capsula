# Capsula

A dynamic animated battery capsule overlay for Android, inspired by Samsung One UI 9's "Now Bar". Shows live battery percentage with beautiful animations as a floating overlay that works over any app and on the lock screen.

## Features

| Feature | Details |
|---|---|
| **Pulse Glow** | Breathing glow alternating Cyan `#3FCAFC` ↔ Green `#5CFF7A` |
| **Fluid Fill** | Animated wave level rising/falling with battery % |
| **Orbit Particles** | 12 colorful particles orbiting the capsule with trails |
| **Live Battery Sync** | Real-time % via `battery_plus`, polling every 30 s |
| **Drag to reposition** | Drag capsule anywhere; position persisted to disk |
| **Resize** | Width (120–320 dp), Height (40–100 dp), Corner radius (0–50 dp) |
| **Opacity** | 20%–100% transparency |

## Primary Colors

- **Vibrant Cyan** `#3FCAFC` — glow, outlines, charging indicator
- **Vibrant Green** `#5CFF7A` — secondary accent, full/charged state

---

## Building the APK

### Option A — GitHub Actions (recommended, automatic)

1. Push this repo to GitHub (the `capsula/` folder at the repo root).
2. The workflow at `.github/workflows/build_apk.yml` triggers automatically on every push to `main`.
3. When the workflow finishes, the APK is available as:
   - **Actions artifact**: `capsula-release-apk` (download from the workflow run page, retained 30 days)
   - **GitHub Release**: auto-tagged `v1.0.0+1-<run_number>` with the APK attached

### Option B — Build manually in Replit or locally

> Requires Flutter SDK installed. In Replit, use a Nix environment with the `flutter` package.

```bash
# From the repo root
cd capsula
flutter pub get
flutter build apk --release
# Output: capsula/build/app/outputs/flutter-apk/app-release.apk
```

---

## Installing the APK on your Android device

1. Transfer `app-release.apk` to your phone (USB, Google Drive, etc.)
2. On the device: **Settings → Apps → Special app access → Install unknown apps** → allow your file manager
3. Tap the APK file and install
4. Open **Capsula**
5. Tap **Launch Overlay** — Android will prompt for **Display over other apps** permission
6. Grant the permission; the capsule appears immediately

---

## Android permissions

| Permission | Why |
|---|---|
| `SYSTEM_ALERT_WINDOW` | Draw the capsule over other apps |
| `FOREGROUND_SERVICE` | Keep the overlay alive while screen is on |
| `WAKE_LOCK` | Prevent overlay from disappearing on AOD |
| `POST_NOTIFICATIONS` | Show the persistent notification (Android 13+) |

---

## Project structure

```
capsula/
├── lib/
│   ├── main.dart                     # App entry + overlayMain() entry point
│   ├── models/
│   │   └── capsule_settings.dart     # Shared state (position, size, animation type)
│   ├── services/
│   │   └── battery_service.dart      # battery_plus wrapper with real-time sync
│   ├── animations/
│   │   ├── pulse_glow_animation.dart # Animation 1: breathing glow
│   │   ├── fluid_fill_animation.dart # Animation 2: wave fill
│   │   └── orbit_particles_animation.dart # Animation 3: orbiting particles
│   ├── widgets/
│   │   └── capsule_widget.dart       # Switches between animations; draggable
│   └── screens/
│       ├── home_screen.dart          # Control panel UI
│       └── overlay_screen.dart       # Overlay-only root widget
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml   # Permissions + overlay service declaration
│   │       └── kotlin/.../MainActivity.kt
│   ├── build.gradle
│   ├── settings.gradle
│   └── gradle.properties
├── pubspec.yaml
└── .github/
    └── workflows/
        └── build_apk.yml             # CI: build + release APK on every push to main
```

---

## Lock screen overlay — limitations & approach

Android does not allow arbitrary apps to draw on the lock screen by default. `flutter_overlay_window` uses `TYPE_APPLICATION_OVERLAY` which appears **above the lock screen** on most devices running Android 8+, but behaviour varies:

| Scenario | Behaviour |
|---|---|
| Screen on, device unlocked | ✅ Overlay visible |
| Screen on, lock screen visible (swipe-to-unlock) | ✅ Visible on most devices (requires `showOnLockScreen` in `Activity`) |
| Screen off (AOD) | ❌ Not possible without System/OEM privileges |
| Secure lock (PIN/pattern/biometric) | ⚠️ Visible above lock screen on some OEMs; blocked on others |

For Samsung AOD / Always-On Display integration (true Now Bar parity), a Samsung Good Lock / One UI SDK integration is required — this is not available to third-party apps via the Play Store.
