# AYRNOW MVP Audit Report

**Date:** 2026-03-09  
**Branch audited:** `release/mvp-integration`  
**Scope:** Repository + Git, MVP modules (Auth, Properties/Units/Leases, Tenant Invites, Rent Payments, Notifications), integration, recovery plan.

---

## A. REPOSITORY / GIT STATUS SUMMARY

| Item | Status |
|------|--------|
| **Current branch** | `release/mvp-integration` |
| **Working tree** | **Dirty** — modified and many untracked files |
| **Modified (tracked)** | 11 files: `ios/Flutter/*.xcconfig`, `lib/core/state/providers.dart`, `linux/flutter/*`, `macos/Flutter/*`, `windows/flutter/*`, `codenexas` |
| **Untracked** | 50+ files: `.flutter-plugins-dependencies`, backend OAuth/DevLogin (AppleLoginRequest, GoogleLoginRequest, DevLoginSeeder, OAuthService, V25 seed), `lib/core/backend/dtos/`, `lib/features/auth/`, `lib/features/common/`, contractor/guard/investor screens, `lib/features/invite/`, `lib/features/invite_accept/`, landlord l20–l38, `lib/features/payments/`, tenant t07–t23, scripts, tests, `docs/MVP_AUDIT_REPORT.md` |
| **Stashes** | 6 (e.g. `feature/auth-hardening`, `finish/m1a-landlord-real-flow`, `fix/local-e2e-contracts`, `feat/community-tab-v1`, `main`) |
| **Branches (MVP-relevant)** | `main`, `release/mvp-integration` (current), `finish/m1a-landlord-real-flow`, `feature/integration-real-backend`, `feat/auth-token-persistence`, `fix/backend-remove-excludes-api-v1-only`, `rescue-invite`, `rescue-wip`, `backend/api-v1-core`, `chore/api-seam-v1` |
| **Current vs main** | Current is **ahead** of main (merge base 71687a1). Large diff: 377 files changed (backend + Flutter integration). |
| **Risky findings** | (1) **API path split:** Backend `build.gradle` **excludes** all `com/ayrnow/api/*Controller.java` and `com/ayrnow/security/**`. Active stack is `controller` package at **`/v1/*`** and `config` package (SecurityConfig, JwtAuthFilter). Flutter calls **`/api/v1/*`** for auth, me, properties, invites — those routes **do not exist** in the current build → login/session/me and property/invite API calls fail. (2) **Payments:** Flutter already uses `v1/payments/intent` and `v1/payments/mine`; `run_local.sh` enables `legacy-v1` so these work. (3) **Untracked work:** New auth, invite, payments, landlord/tenant screens and tests are untracked; risk of loss if not committed. (4) **Mock usage:** Community, tenant transfer, household, rent board, tickets, jobs, approvals still use mock repos; notifications screen uses `_MockNotification`. (5) **Invite accept:** Only in excluded `api.InviteController`; controller package has no invite-accept endpoint. (6) **Create property/unit:** Only in excluded `api.PropertyController`/`api.UnitController`; controller package has list-only PropertyController. |
| **Main** | Main is behind current; current holds integration work. Main is not MVP-complete without this branch. |

---

## B. MVP MODULE AUDIT TABLE

| Module | Frontend | Backend (active build) | API wiring | Tests | Simulator | Blockers | Recommended next step |
|--------|----------|------------------------|------------|-------|-----------|----------|------------------------|
| **1. Auth** | LoginScreen (lib/ui/login_screen.dart), AuthGate, initialSessionProvider, authControllerProvider. Routes /login, /home. | controller.AuthController at **/v1/auth** (login, register, refresh). config.JwtAuthFilter, config.SecurityConfig. AuthService, LoginResponse (token, userId, role, email). | **BROKEN:** Flutter calls `/api/v1/auth/login` and `/api/v1/me`; backend only exposes `/v1/auth/*` and `/v1/me`. | Backend: AuthControllerTest, AuthFlowIntegrationTest (legacy paths). | Will work once Flutter uses /v1. | Path mismatch. | **Fix:** Use `/v1/auth/login` and `/v1/me` in Flutter (providers.dart). |
| **2. Properties / Units / Leases** | L-25 list, L-20 add property, L-22 detail, L-21 add unit, L-24 unit detail. | controller.PropertyController at **/v1/properties** (GET list, GET {id}/units only). No create property/unit in controller (those are in excluded api package). | **Partial:** List wired in Flutter to `/api/v1/properties/...` → 404. Create property/unit not available in active backend. | Backend: PropertyUnitIntegrationTest. Flutter: property_detail_empty_units_test, add_unit_validation_test (untracked). | List would work after path fix; create needs backend or api inclusion. | Path + missing create endpoints. | Use `/v1/properties` and `/v1/properties/{id}/units` in Flutter for list; add create to controller or un-exclude api for properties. |
| **3. Tenant Invites / Onboarding** | InviteApi (createUnitInvite, acceptInvite). invite_accept_screen, invite_household_member_screen. | controller.UnitInviteController at **/v1/units/{unitId}/invites** (POST create only). No invite-accept in controller; api.InviteController (excluded) has accept. | **Partial:** Create would work at `/v1/units/{id}/invites`; Flutter uses `/api/v1/...` → 404. Accept endpoint missing in active build. | invite_api_error_test, invite_dto_test, invite_accept_missing_token_test (untracked). | Create works after path fix; accept broken until backend adds accept. | Path + missing accept. | Use `/v1/units/{id}/invites` for create; add POST /v1/invites/accept/{token} in backend or un-exclude InviteController. |
| **4. Rent Payments** | t10_pay_rent, payments_api (createPaymentIntent, list). | controller.PaymentController at **/v1/payments** (intent, mine). run_local.sh sets `local,legacy-v1`. | **Wired:** Flutter already calls `v1/payments/intent` and `v1/payments/mine`. | payments_api_error_test (untracked). | Works with backend running and legacy-v1. | None. | Keep; ensure Stripe config and error/loading UI. |
| **5. Notifications + deep links** | NotificationsScreen (I-10) uses **_MockNotification** list. | controller.NotificationController at **/v1/notifications** (list, mark read). | **Not wired:** App does not call API; UI is mock-only. | Backend: NotificationControllerTest. | Mock only. | App not calling real API. | **Backlog:** Wire to GET /v1/notifications; loading/empty/error; deep link parsing. |

---

## C. MERGE / RECOVERY ASSESSMENT

| Category | Items |
|----------|--------|
| **Preserve** | All commits on release/mvp-integration. Untracked MVP screens (auth, invite, payments, landlord/tenant), scripts, tests, backend dev seeds. config.SecurityConfig and /v1/* controller set. |
| **Merge** | release/mvp-integration → main after path fix and smoke test. Small branches (fix/api-path-v1, etc.) merge into release/mvp-integration first. |
| **Isolate** | Contractor, guard, investor, community (beyond MVP) stay on feature branches. |
| **Backlog** | Notifications real API + deep links; create property/unit in controller or api un-exclude; invite accept in controller; maintenance/tickets real API. |
| **Duplicated** | Two controller layers in repo: `api` (excluded, /api/v1) and `controller` (/v1). Only one is active per build. No duplicate same-path endpoints at runtime. |
| **Stranded** | Stashes may contain useful auth/household/e2e work; review before discarding. |
| **Safest recovery strategy** | (1) Fix Flutter API base path to `/v1` for auth and me (single scoped branch, small commit). (2) Verify login and session restore. (3) Extend to properties/invites paths. (4) Commit untracked MVP files. (5) Add missing controller endpoints (invite accept, create property/unit) or document and backlog. (6) Merge to main after smoke test. |

---

## D. EXECUTION PLAN (SMALL SCOPED BRANCHES)

| Step | Branch | Objective | Files likely involved | Why now | Verification | Merge criteria |
|------|--------|-----------|------------------------|---------|---------------|----------------|
| 1 | `fix/api-path-v1` | Wire Flutter auth and me to /v1 | lib/core/state/providers.dart | Backend only serves /v1; login and session restore currently fail. | After change: start backend, run app, login → 200 and session. | Login and GET /v1/me succeed. |
| 2 | (same or follow-up) | Wire properties list to /v1 | lib/features/landlord/l22_property_detail.dart, l21_add_unit.dart, l25 if any | Unblock landlord list/detail. | GET /v1/properties and /v1/properties/{id}/units from app. | Properties list and units list load. |
| 3 | (same or follow-up) | Wire invite create to /v1 | lib/features/invite/invite_api.dart | Unblock invite creation. | POST /v1/units/{id}/invites from app. | Invite create succeeds. |
| 4 | `chore/commit-untracked-mvp` | Track MVP screens and tests | New/untracked: auth, common, invite, invite_accept, payments, landlord/tenant screens, dtos, scripts, tests | Prevent loss. | git status clean for MVP paths. | All MVP-relevant files tracked. |
| 5 | `fix/invite-accept-backend` or backlog | Add invite accept to controller | Backend: controller (new endpoint or UnitInviteController), service/repo | Accept flow required for onboarding. | POST /v1/invites/accept/{token} returns 2xx. | Invite accept works end-to-end. |

---

## E. FIRST ACTION

**Chosen:** Fix Flutter auth and me to use `/v1` so login and session restore work with the active backend.

**Action:** Create branch `fix/api-path-v1` from current. In `lib/core/state/providers.dart`: change `$baseUrl/api/v1/me` to `$baseUrl/v1/me` and `$baseUrl/api/v1/auth/login` to `$baseUrl/v1/auth/login`. Ensure Me response parsing supports backend shape (id, email, name, role at top level).

**Verification:**
- Backend: `cd backend && ./scripts/run_local.sh`
- Flutter: `flutter run -d chrome` or simulator; open app, enter dev credentials (e.g. from DevDataSeeder/DevLoginSeeder), login → expect home (no 404).
- Optional: `curl -s -X POST http://localhost:8081/v1/auth/login -H "Content-Type: application/json" -d '{"email":"...","password":"..."}'` → token and userId.

**Next:** After merge, wire properties and invites to /v1 in Flutter; then commit untracked MVP files; then add invite-accept endpoint or backlog.

---

## F. VERIFICATION COMMANDS (LOCAL)

**Backend (from repo root):**
```bash
cd backend && ./scripts/run_local.sh
# Expect: Started AyrnowBackendApplication; port 8081 (or SERVER_PORT).
```

**Auth (backend running):**
```bash
curl -s -X POST http://localhost:8081/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"landlord@demo.com","password":"<dev-password>"}'
# Expect: JSON with token, userId, role (or 401 if wrong password).
```

**Me (with token from login):**
```bash
curl -s http://localhost:8081/v1/me -H "Authorization: Bearer <ACCESS_TOKEN>"
# Expect: JSON with id, email, name, role.
```

**Flutter (after fix/api-path-v1):**
```bash
export PATH="/opt/flutter/bin:$PATH"
flutter pub get
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
# Or: flutter run -d <ios-simulator-id>
# Open app → Login with dev credentials → expect navigation to home (no 404).
```

**Health (no auth):**
```bash
curl -s http://localhost:8081/api/v1/health
# Expect: {"status":"ok", ...}
```
