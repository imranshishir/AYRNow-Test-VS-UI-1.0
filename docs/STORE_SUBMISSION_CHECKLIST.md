# AYRNOW Store Submission Checklist

Use before submitting to App Store and Google Play.

---

## App Store (iOS)

- [ ] Apple Developer account active; app created in App Store Connect.
- [ ] Version and build number set (Info.plist / Xcode).
- [ ] Release build signed with distribution cert and provisioning profile.
- [ ] Screenshots and metadata prepared (App Store Connect).
- [ ] Privacy policy URL if required.
- [ ] No “Skip login (dev)” or test-only UI in release (or hidden behind build flag).
- [ ] API base URL points to production backend.
- [ ] Archive uploaded via Xcode or Transporter; submit for review.
- [ ] Export compliance / encryption: answer as appropriate (e.g. no custom encryption or standard HTTPS only).

---

## Google Play (Android)

- [ ] Google Play Console account; app created.
- [ ] Release build: AAB (app bundle) recommended; signing with upload key.
- [ ] Version code and version name incremented (build.gradle).
- [ ] Store listing: short/long description, screenshots, graphics.
- [ ] Privacy policy URL if required.
- [ ] Content rating questionnaire completed.
- [ ] Target SDK and permissions declared; no unnecessary permissions.
- [ ] Internal testing track used first, then production (or staged rollout).
- [ ] API base URL points to production backend.

---

## Common

- [ ] Backend deployed and stable (see AWS_DEPLOYMENT_RUNBOOK.md).
- [ ] No secrets or test keys in release build.
- [ ] ENVIRONMENT_VARIABLES.md and RELEASE_CHECKLIST.md reviewed.
