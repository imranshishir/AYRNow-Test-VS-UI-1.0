# AYRNOW Release Checklist

Use this before tagging a release or merging to main. No Docker in local workflow.

---

## Pre-release

- [ ] Push block resolved (no secrets in repo; see BRANCH_RECOVERY_PLAN.md).
- [ ] Release branch is fix/restore-register-and-property-nav (or release/mvp-ship).
- [ ] `flutter analyze` clean (or only known non-blocking hints).
- [ ] `flutter test` passes (or critical tests only).
- [ ] Backend `./gradlew build` passes (no Docker).

---

## MVP slices

- [ ] **Auth:** Login, Register, session restore work; loading/error/success UI; minimal tests.
- [ ] **Properties/Units/Leases:** List, Add Property (POST /v1/properties), detail, units list; loading/empty/error UI.
- [ ] **Invites/Onboarding:** Create invite, Accept invite (backend + Flutter); UI states.
- [ ] **Stripe Payments:** Intent + list wired; keys from env; loading/error/success UI.
- [ ] **Notifications:** App calls GET /v1/notifications; deep link routing if required.

---

## API and config

- [ ] All Flutter API calls use /v1 (no /api/v1 for active backend).
- [ ] Production API base URL from env/config (no hardcoded localhost in release build).
- [ ] ENVIRONMENT_VARIABLES.md updated; no secrets in repo.

---

## Deploy and store

- [ ] AWS_DEPLOYMENT_RUNBOOK.md followed; backend deployable to AWS (no Docker requirement in runbook).
- [ ] MOBILE_RELEASE_RUNBOOK.md followed; iOS and Android build and sign.
- [ ] STORE_SUBMISSION_CHECKLIST.md completed for App Store and Google Play.

---

## Final

- [ ] FINAL_HANDOFF.md updated with current state and owner.
- [ ] Version/build numbers bumped for release.
- [ ] Tag or merge to main as appropriate.
