# AYRNOW Final Handoff

**Date:** 2026-03-09  
**Purpose:** Handoff for finishing MVP, AWS deploy, and store submission.

---

## 1. Current repo reality

- **Release branch:** **fix/push-secret-and-release-base** (history cleaned; safe to push after you rotate Stripe Test Secret). Alternative base: fix/restore-register-and-property-nav (still has secret in history).
- **Push status:** On **fix/push-secret-and-release-base**, backend/.env is untracked and removed from history. Rotate the exposed Stripe Test Secret Key in Dashboard, then push should pass (see ENVIRONMENT_VARIABLES.md).
- **Stack:** Flutter (Riverpod) + Spring Boot 3.2 (Java 17). Backend active stack: controller package at /v1/*; api package excluded in build.gradle.
- **Working:** Auth (login/register/me to /v1), property list (GET /v1/properties), invite create (POST /v1/units/:id/invites), payments (v1/payments intent/mine), Skip login (dev) for testing. Port 8081 for iOS/Android.
- **Fixed on release branches:** Add Property (POST /v1/properties on fix/property-create-and-v1-paths); invite accept (POST /v1/invites/accept/{token} on fix/invite-accept-and-notifications); all Flutter calls use /v1; notifications wired to GET /v1/notifications; production API URL in release (fix/release-config-and-store-readiness); Skip login gated by kDebugMode; Android applicationId com.ayrnow.app and release signing from key.properties.

---

## 2. Recommended release branch

**fix/push-secret-and-release-base** (recommended; history cleaned). Optionally rename to release/mvp-ship. All stabilization and MVP work should branch from and merge into this branch until release.

---

## 3. Top blockers

1. ~~**Push block:**~~ Resolved on fix/push-secret-and-release-base (history rewritten). **You must rotate Stripe Test Secret** in Dashboard before push.
2. ~~**Add Property:**~~ Done on fix/property-create-and-v1-paths.
3. ~~**Invite accept:**~~ Done on fix/invite-accept-and-notifications.
4. ~~**Notifications:**~~ Done on fix/invite-accept-and-notifications.
5. ~~**Secrets and env:**~~ Production API URL set in release; ENVIRONMENT_VARIABLES.md and runbooks updated.

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
