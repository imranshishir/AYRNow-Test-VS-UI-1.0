# AYRNOW Release Fix Plan

**Date:** 2026-03-09  
**Purpose:** Prioritized fixes to reach push-safe, AWS-deployable, and store-submission-ready state.

---

## Immediate blockers (do first)

These block push, deploy, or store submission and must be fixed before any release.

| Priority | Action | Owner | Details |
|----------|--------|-------|---------|
| 1 | ~~Resolve push block and secret hygiene~~ | **Done** | On `fix/push-secret-and-release-base`: backend/.gitignore updated, backend/.env untracked, history rewritten. **You must still rotate Stripe Test Secret** in Dashboard. See ENVIRONMENT_VARIABLES.md. |
| 2 | Fix production JWT config | Backend | Set `jwt.secret` in application-prod.yml from ${JWT_SECRET}, or change JwtProperties to use auth.jwt.secret so prod uses JWT_SECRET. Align StartupValidator with same key. See SECURITY_FINDINGS.md #2. |
| 3 | ~~Untrack and stop tracking backend/.env~~ | **Done** | .env is in backend/.gitignore and root .gitignore; not tracked. |

---

## Next engineering slice (MVP functionality)

Get Add Property and /v1 paths working; then invite-accept and notifications.

| Priority | Action | Owner | Details |
|----------|--------|-------|---------|
| 4 | Backend: POST /v1/properties | Backend | Add create method to PropertyController; wire PropertyService and existing DTOs (CreatePropertyRequest if present, else define). See MISSING_RELEASE_ITEMS.md. |
| 5 | Flutter: /v1 paths only | Frontend | In l20_add_property.dart, l21_add_unit.dart, l22_property_detail.dart, invite_api.dart replace `/api/v1` with `/v1`. See MISSING_RELEASE_ITEMS.md "Frontend code" table. |
| 6 | Flutter: Do not send API with dev-bypass | Frontend | In l20 (and any similar callers), when token is null/empty/dev-bypass, do not call API (show "Please sign in" or gate with kDebugMode). |
| 7 | Backend: Invite-accept endpoint | Backend | Add e.g. POST /v1/invites/accept/{token} (or PATCH); update invite status; return session/redirect info. Wire Flutter invite_accept_screen to this endpoint. |
| 8 | Flutter: Notifications to GET /v1/notifications | Frontend | Replace mock list in notifications_screen.dart with API call; add loading/empty/error states. |

---

## Pre-AWS pass

Before deploying backend to AWS production.

| Priority | Action | Owner | Details |
|----------|--------|-------|---------|
| 9 | CORS for production | Backend | Set CORS_ALLOWED_ORIGINS to production front-end origin(s); do not use * in prod. Document in ENVIRONMENT_VARIABLES.md. |
| 10 | Secrets from env only | Backend/Ops | No .env in repo; use env vars or AWS Secrets Manager. Document all required vars in ENVIRONMENT_VARIABLES.md. |
| 11 | Health check path | Docs/Ops | Runbook: use /api/v1/health (current backend) or add /v1/health and document. |
| 12 | StartupValidator vs JwtService | Backend | Ensure single source of truth for JWT secret (jwt.secret or auth.jwt.secret) and StartupValidator validates the same. |

---

## Pre-store-submission pass

Before submitting to App Store and Google Play.

| Priority | Action | Owner | Details |
|----------|--------|-------|---------|
| 13 | Production API base URL in release build | Frontend | Add mechanism (build flavor, env at build time, or config) so release build uses production API URL (HTTPS). No hardcoded localhost in release. |
| 14 | Gate Skip login (dev) with kDebugMode | Frontend | lib/ui/login_screen.dart: wrap "Skip login (dev)" and dev-bypass token setting in `if (kDebugMode) { ... }`. |
| 15 | Android: applicationId and release signing | Frontend/DevOps | Set final applicationId (e.g. com.ayrnow.app). Configure release signing (keystore, key.properties); do not use debug signing for release. See MOBILE_RELEASE_RUNBOOK. |
| 16 | iOS: Signing and bundle ID | Frontend/DevOps | Confirm bundle ID and distribution signing per MOBILE_RELEASE_RUNBOOK and STORE_SUBMISSION_CHECKLIST. |
| 17 | Store assets and metadata | Product/Marketing | Screenshots, descriptions, privacy policy URL, content rating (Play), export compliance (App Store) per STORE_SUBMISSION_CHECKLIST. |

---

## Branch recommendation

- **First branch:** `fix/push-secret-and-release-base`  
  - Scope: Unblock push; remove/rotate secret; untrack .env; optionally rename to release/mvp-ship.  
- **Second branch:** `fix/property-create-and-v1-paths`  
  - Scope: POST /v1/properties; Flutter l20/l21/l22/invite_api to /v1; dev-bypass handling.  
- **Third branch:** `fix/invite-accept-and-notifications`  
  - Scope: Backend invite-accept; Flutter invite accept + notifications screen to GET /v1/notifications.  
- **Fourth branch:** `fix/prod-config-and-store-readiness`  
  - Scope: Prod JWT fix; CORS; production API URL in app; gate Skip login; Android signing and applicationId; store checklists.

---

## Verification after each slice

- Run `flutter analyze` and `flutter test` (or critical tests).
- Run backend `./gradlew build`.
- Smoke-test: login, property list, add property (after slice 2), invite create, invite accept (after slice 3), notifications (after slice 3).
- Before AWS: Deploy to staging and verify health, auth, and CORS.
- Before store: Build release iOS/Android with production API URL; confirm no "Skip login" in release; confirm signing and bundle ID.
