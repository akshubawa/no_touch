# No Touch

**Package:** `app.significantinfotech.notouch`

Android-only Flutter app that blocks accidental touch input while kids use your phone. A native overlay consumes all touches; a draggable floating shield unlocks touch only after your chosen gesture and confirmation.

## Architecture

| Layer | Responsibility |
|-------|----------------|
| **Flutter (UI)** | Home activation, settings, themes — Cubit + feature folders (MVVM-style) |
| **Method channel** | `TouchLockPlugin` bridges permissions, start/stop, status events |
| **Kotlin services** | Foreground service, full-screen blocker overlay, floating unlock control |
| **Accessibility** | Volume Up + Down unlock, service reliability, future auto-lock hooks |

## Setup

1. Install [Flutter](https://flutter.dev) and Android SDK.
2. Connect a physical Android device (overlays are unreliable on emulators).
3. Run:

```bash
flutter pub get
flutter run
```

## Release builds

Signing is configured via `android/key.properties` and `android/app/upload-keystore.jks` (both are gitignored).

```bash
# Play Store upload (recommended)
flutter build appbundle --release

# APK for sideloading / testing
flutter build apk --release
```

Outputs:

- App bundle: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

## First-run permissions

1. **Display over other apps** (required) — tap the permission card on the home screen.
2. **Accessibility service** (recommended) — enables volume-key unlock and keeps the lock stable.
3. **Notifications** (Android 13+) — allow when prompted for the foreground countdown/active notification.

## Usage

1. Open **Settings** and choose activation delay, unlock gesture, and theme.
2. On the home screen, tap **Enable touch lock**.
3. Switch to the app/video within the countdown window.
4. When the timer ends, touch is blocked system-wide.
5. Use the floating shield with your unlock gesture, confirm in the dialog, and touch is restored.

### Unlock gestures

- **Triple tap** — tap the floating shield three times within ~600ms.
- **Long press** — hold the shield for 3 seconds.
- **Volume Up + Down** — press both volume keys together (requires accessibility service).

## Project structure

```
lib/
  app/                 # App shell, theming
  core/                # Platform channel, shared widgets
  features/
    home/              # Activation flow
    settings/          # Delay, gestures, theme
android/.../kotlin/
  TouchLockPlugin.kt
  service/TouchLockForegroundService.kt
  overlay/TouchOverlayManager.kt
  TouchLockAccessibilityService.kt
```

## Notes

- Touch lock is **Android only**; iOS does not allow this class of system-wide touch blocking.
- Some OEMs aggressively kill background services — enable accessibility and disable battery optimization for best results.
- Auto-lock in specific kids apps can be added on top of `TouchLockAccessibilityService` window events.
