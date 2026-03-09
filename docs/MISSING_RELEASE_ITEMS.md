# AYRNOW Missing Release Items

**Date:** 2026-03-09  
**Purpose:** List every missing item required for Git hygiene, backend production deploy, iOS/Android release, and store submission.

---

## Git / repo hygiene

| Item | Status | Notes |
|------|--------|------|
| Remove `backend/.env` from tracking | **Done** | On `fix/push-secret-and-release-base`: untracked and history rewritten. |
| Ensure `.env` never committed again | **Done** | Root and `backend/.gitignore` both list .env. |
| Remove secret from history (commit 1f440d0) | **Done** | History rewritten with `git filter-branch` on that branch. |
| Rotate Stripe Test Secret Key | **Required** | You must rotate in Stripe Dashboard (see ENVIRONMENT_VARIABLES.md). |
| No other secret files tracked | **Verified** | No other committed files contain real keys; only docs use placeholders. |

---

## Backend production deploy

| Item | Status | Notes |
|------|--------|------|
| POST /v1/properties | **Missing** | PropertyController has only GET list and GET /{id}/units. Add create and wire PropertyService. |
| Invite-accept endpoint | **Missing** | e.g. POST /v1/invites/accept/{token} or PATCH; UnitInviteController has create invite only. |
| Prod JWT config | **Broken** | application-prod must set `jwt.secret` (or align JwtProperties with auth.jwt.secret). See SECURITY_FINDINGS.md #2. |
| CORS for production | **Missing** | Set CORS_ALLOWED_ORIGINS to real origin(s); do not use * in prod. |
| Secrets from env only | **Missing** | No committed .env; use env vars or AWS Secrets Manager. Document in ENVIRONMENT_VARIABLES.md. |
| Health check path documented | **Optional** | Backend exposes /api/v1/health; runbook says "/v1/health or /api/v1/health" – align docs or add /v1/health. |
| StartupValidator property alignment | **Missing** | StartupValidator checks auth.jwt.secret and stripe.*; ensure JwtService reads same secret (jwt.secret). |

---

## iOS release

| Item | Status | Notes |
|------|--------|------|
| Production API base URL | **Missing** | No build-time or runtime config for production URL; default is localhost:8081. |
| Skip login hidden in release | **Missing** | Gate with kDebugMode so release build does not show "Skip login (dev)". |
| Bundle ID | **Verify** | Info.plist uses $(PRODUCT_BUNDLE_IDENTIFIER); confirm in Xcode project. |
| Release signing | **Verify** | Distribution cert and provisioning profile per MOBILE_RELEASE_RUNBOOK. |
| Icons / splash | **Verify** | AGENTS.md mentions assets/icons may be missing; ensure no placeholders for store. |
| Version / build number | **Present** | From pubspec and FLUTTER_BUILD_NAME/NUMBER. |

---

## Android release

| Item | Status | Notes |
|------|--------|------|
| applicationId | **Placeholder** | Currently `com.example.ayrnow` in android/app/build.gradle.kts; replace with final bundle ID. |
| Release signing | **Missing** | build.gradle.kts uses `signingConfigs.getByName("debug")` for release; need upload/production keystore and signingConfigs. |
| key.properties / keystore | **Missing** | Not committed (correct); must be created and configured per MOBILE_RELEASE_RUNBOOK. |
| Production API base URL | **Missing** | Same as iOS; no production URL for release. |
| Skip login hidden in release | **Missing** | Same as iOS. |
| Permissions | **Verify** | No unnecessary permissions; purpose strings if required. |

---

## App Store submission

| Item | Status | Notes |
|------|--------|------|
| Production API URL in app | **Missing** | Release build must call production backend. |
| No "Skip login" or test-only UI in release | **Missing** | Gate dev-only UI. |
| Privacy policy URL | **Verify** | If required by App Store, add and document. |
| Screenshots and metadata | **Verify** | Per STORE_SUBMISSION_CHECKLIST. |
| Signing and archive | **Verify** | Per runbook and checklist. |
| Export compliance / encryption | **Verify** | Answer as appropriate (e.g. HTTPS only). |

---

## Google Play submission

| Item | Status | Notes |
|------|--------|------|
| applicationId final | **Missing** | Replace com.example.ayrnow. |
| Release AAB with production signing | **Missing** | Configure signing and build AAB. |
| Production API URL in app | **Missing** | Same as App Store. |
| No test-only UI in release | **Missing** | Same as App Store. |
| Store listing (description, screenshots) | **Verify** | Per checklist. |
| Privacy policy URL | **Verify** | If required. |
| Content rating | **Verify** | Questionnaire completed. |
| Target SDK and permissions | **Verify** | Declared; no unnecessary permissions. |

---

## Frontend code (exact files / paths to fix)

| File | Current | Required |
|------|---------|----------|
| lib/features/landlord/l20_add_property.dart | `$baseUrl/api/v1/properties` (POST) | `$baseUrl/v1/properties`; do not send API request when token is dev-bypass in release. |
| lib/features/landlord/l21_add_unit.dart | `$baseUrl/api/v1/properties/${widget.propertyId}/units` | `$baseUrl/v1/properties/${widget.propertyId}/units` |
| lib/features/landlord/l22_property_detail.dart | `$baseUrl/api/v1/properties/$propertyId/units` | `$baseUrl/v1/properties/$propertyId/units` |
| lib/features/invite/invite_api.dart | `$baseUrl/api/v1/units/$unitId/invites` and `$baseUrl/api/v1/invites/accept/$inviteUrlToken` | `$baseUrl/v1/units/$unitId/invites` and (when backend exists) `$baseUrl/v1/invites/accept/$inviteUrlToken` |
| lib/ui/login_screen.dart | Skip login button always visible | Wrap in `if (kDebugMode) { ... }` |
| lib/features/common/notifications_screen.dart | Mock list only | Call GET /v1/notifications with auth; loading/empty/error states. |
| lib/core/backend/api_config.dart | defaultBaseUrl = localhost:8081 | Production URL from build flavor or env (no hardcoded prod URL in repo). |
| lib/core/backend/api_base_url_io.dart | Platform default 8081 | For release, use production base URL when configured (e.g. from same config/flavor). |

---

## Backend code (exact additions)

| Component | Missing | Notes |
|-----------|--------|------|
| PropertyController | POST /v1/properties | Create property; body and response per existing DTOs (e.g. CreatePropertyRequest / PropertyResponse) and PropertyService. |
| UnitInviteController (or new controller) | POST /v1/invites/accept/{token} (or equivalent) | Accept invite by token; return session or redirect info; update invite status. |
| application-prod.yml | jwt.secret: ${JWT_SECRET} | So JwtService gets prod secret. Align with StartupValidator if it checks auth.jwt.secret. |

---

## Documentation / operations

| Doc | Status | Missing |
|-----|--------|--------|
| RELEASE_CHECKLIST.md | Present | Execution not done; no updates needed for this audit. |
| ENVIRONMENT_VARIABLES.md | Present | Add prod JWT and CORS notes; ensure no secrets in examples. |
| AWS_DEPLOYMENT_RUNBOOK.md | Present | Health path: use /api/v1/health or document /v1/health if added. |
| MOBILE_RELEASE_RUNBOOK.md | Present | Signing and bundle ID steps; production API URL. |
| STORE_SUBMISSION_CHECKLIST.md | Present | No gap. |
| FINAL_HANDOFF.md | Present | Update after fixes with current state. |
