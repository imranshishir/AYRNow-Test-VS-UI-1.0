# AYRNOW Final Handoff

**Date:** 2026-03-09  
**Purpose:** Handoff for finishing MVP, AWS deploy, and store submission.

---

## 1. Current repo reality

- **Release branch:** fix/restore-register-and-property-nav (~20 commits ahead of main).
- **Push status:** Blocked by GitHub (Stripe secret in history, commit 1f440d0). Must resolve before pushing (see BRANCH_RECOVERY_PLAN.md).
- **Stack:** Flutter (Riverpod) + Spring Boot 3.2 (Java 17). Backend active stack: controller package at /v1/*; api package excluded in build.gradle.
- **Working:** Auth (login/register/me to /v1), property list (GET /v1/properties), invite create (POST /v1/units/:id/invites), payments (v1/payments intent/mine), Skip login (dev) for testing. Port 8081 for iOS/Android.
- **Not working / gaps:** Add Property (no POST /v1/properties); invite accept (no backend endpoint); some Flutter calls still /api/v1 (l20, l21, l22, invite_api); notifications mock-only; no production API URL in release build.

---

## 2. Recommended release branch

**fix/restore-register-and-property-nav** (optionally renamed to release/mvp-ship after push unblock). All stabilization and MVP work should branch from and merge into this branch until release.

---

## 3. Top blockers

1. **Push block:** Stripe secret in repo history; resolve via GitHub allow, history rewrite, or new branch without .env.
2. **Add Property:** Backend POST /v1/properties missing; Flutter l20 uses /api/v1 → change to /v1 and add backend create.
3. **Invite accept:** Backend endpoint missing; Flutter to use /v1 when available.
4. **Notifications:** Wire app to GET /v1/notifications; deep links if required.
5. **Secrets and env:** All secrets from env; document in ENVIRONMENT_VARIABLES.md; production API URL for mobile release.

---

## 4. First three implementation branches

| Order | Branch | Objective | Key files |
|-------|--------|-----------|-----------|
| 1 | **fix/push-secret-and-release-base** | Unblock push; establish clean release base | Remove or allow secret; optionally rename branch to release/mvp-ship. |
| 2 | **fix/property-create-and-v1-paths** | Add Property working + all property/unit calls to /v1 | Backend: PropertyController, PropertyService. Flutter: l20_add_property, l21_add_unit, l22_property_detail (paths to /v1). |
| 3 | **fix/invite-accept-and-notifications** | Invite accept endpoint + Flutter; wire notifications screen | Backend: controller invite accept. Flutter: invite_api or invite_accept_screen; NotificationsScreen to GET /v1/notifications. |

---

## 5. Plan to AWS deployed + store-ready

| Phase | Steps |
|-------|--------|
| **Stabilize** | Resolve push block; run RELEASE_CHECKLIST pre-release items; fix any remaining analyze/test failures. |
| **MVP** | Execute fix/property-create-and-v1-paths; fix/invite-accept-and-notifications; ensure loading/empty/error/success UI and minimal tests per slice. |
| **Config** | ENVIRONMENT_VARIABLES.md; production API URL; Stripe and JWT from env only. |
| **AWS** | Follow AWS_DEPLOYMENT_RUNBOOK.md; deploy backend (e.g. EC2/ECS/EB); RDS; health check; Stripe webhook URL. |
| **Mobile** | Follow MOBILE_RELEASE_RUNBOOK.md; build iOS/Android release with production API URL; remove or gate dev-only UI. |
| **Store** | Follow STORE_SUBMISSION_CHECKLIST.md; submit to App Store and Google Play after smoke tests. |
| **Handoff** | Update this FINAL_HANDOFF.md with owner and current state when handing off. |

---

## 6. Required docs (all in docs/)

- RELEASE_READINESS_AUDIT.md  
- BRANCH_RECOVERY_PLAN.md  
- MVP_GAP_LIST.md  
- RELEASE_CHECKLIST.md  
- ENVIRONMENT_VARIABLES.md  
- AWS_DEPLOYMENT_RUNBOOK.md  
- MOBILE_RELEASE_RUNBOOK.md  
- STORE_SUBMISSION_CHECKLIST.md  
- FINAL_HANDOFF.md (this file)

---

## 7. Hard rules (reminder)

- No Docker in local AYRNOW workflow.
- Small scoped branches/PRs.
- Preserve current UI style.
- MVP only: Auth, Properties/Units/Leases, Invites, Stripe Payments, Notifications + deep links.
- Contractor and Maintenance out of MVP unless blocker.
- Every slice: loading/empty/error/success UI, backend validation, logs/errors, minimal tests, Android + iOS simulators.
