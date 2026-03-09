# AYRNOW Mobile Release Runbook

Use for building and signing iOS and Android apps for store submission. No Docker.

---

## 1. Prerequisites

- Flutter SDK (3.32.x or compatible); Xcode (iOS); Android SDK (Android).
- **Production API base URL:** App must call production backend in release builds (not localhost). Configure via runtime config, build flavor, or env (see ENVIRONMENT_VARIABLES.md).
- iOS: Apple Developer account; provisioning profile and signing cert.
- Android: Keystore for release signing.

---

## 2. Version and build numbers

- **pubspec.yaml:** Bump `version:` (e.g. 1.0.0+1 → 1.0.1+2; build number after +).
- **iOS:** CFBundleShortVersionString and CFBundleVersion in ios/Runner/Info.plist (or via Xcode).
- **Android:** versionName and versionCode in android/app/build.gradle.

---

## 3. Android release build

```bash
flutter clean
flutter pub get
flutter build apk --release
# or: flutter build appbundle --release   # for Play Store
```

- Signing: Configure android/app/build.gradle with signingConfigs (keystore path, storePassword, keyPassword from env or secure storage). Do not commit keystore or passwords.
- Output: build/app/outputs/flutter-apk/app-release.apk or build/app/outputs/bundle/release/app-release.aab.

---

## 4. iOS release build

- Open ios/Runner.xcworkspace in Xcode.
- Select Runner target → Signing & Capabilities; set Team and provisioning profile.
- Select “Any iOS Device” or archive target; Product → Archive.
- Distribute App (App Store Connect or ad hoc).

Or command line:

```bash
flutter build ios --release
# Then use Xcode to archive and upload, or use fastlane if configured.
```

- Ensure release build uses production API URL (no 127.0.0.1).

---

## 5. Verification

- Install release build on device; confirm login and key flows work against production backend.
- Confirm no debug logs or dev-only UI (e.g. “Skip login (dev)” should be removed or gated for non-release builds if desired).

---

## 6. Store submission

Follow STORE_SUBMISSION_CHECKLIST.md for App Store and Google Play steps.
