# AYRNOW Release Readiness Audit

**Date:** 2026-03-09  
**Audit branch:** fix/restore-register-and-property-nav  
**Purpose:** Stabilize repo, finish MVP, prepare AWS deploy + store submission.

---

## 1. Repo reality

| Area | Status | Notes |
|------|--------|-------|
| **Current branch** | fix/restore-register-and-property-nav | ~20 commits ahead of main; contains recovery (Register link, Add Property nav, auth/me/register to /v1, durable screens commit, inviteRepoProvider, port 8081, Skip login dev). |
| **Git push** | **Blocked** | GitHub push protection: Stripe secret in history (commit 1f440d0, backend/.env). Must resolve before pushing this branch. Options: allow secret via GitHub security, or rewrite history to remove .env. |
| **Backend** | Spring Boot 3.2, Java 17 | build.gradle excludes api/* controllers and security/**; active stack is controller package at /v1/*. run_local.sh uses port 8081, profiles local+legacy-v1. |
| **Frontend** | Flutter, Riverpod | Auth gate → login or app shell. Login/register/property list/add property reachable. API base URL 8081 for iOS/Android. Skip login (dev) for testing without backend. |
| **MVP scope** | Auth, Properties/Units/Leases, Invites, Payments, Notifications | Contractor/Maintenance out of MVP. |

---

## 2. What exists vs wired vs blocking

### Auth
- **Exists:** Login screen, Register screen, AuthGate, AuthController (login/register/logout), token persistence, GET /v1/me, POST /v1/auth/login, POST /v1/auth/register. DevLoginSeeder (landlord@demo.com, tenant@demo.com / ayrnow123).
- **Wired:** Yes. Flutter uses /v1 for auth and me. Register submits to API.
- **Blocks release:** None for happy path. Add loading/error/success UI and minimal tests if not present.

### Properties / Units / Leases
- **Exists:** L-25 Property list, L-20 Add Property, L-22 Property detail, L-21 Add Unit. Backend: GET /v1/properties, GET /v1/properties/{id}/units. landlordPropertiesProvider, landlordPropertiesRefreshProvider.
- **Wired:** List wired to GET /v1/properties. Add Property screen calls **POST /api/v1/properties** → 404 (no POST in controller). l21/l22 use /api/v1 in places → should be /v1.
- **Blocks release:** Add Property 404. Unify all property/unit calls to /v1; add POST /v1/properties (and create unit if needed) in backend.

### Tenant Invites / Onboarding
- **Exists:** invite_household_member_screen, invite_accept_screen, InviteApi, inviteRepoProvider (POST /v1/units/:id/invites with {email}). Backend: POST /v1/units/{id}/invites (create). No invite-accept in controller.
- **Wired:** Create invite via inviteRepoProvider works. Accept flow: Flutter invite_api uses /api/v1/invites/accept → not in controller.
- **Blocks release:** Invite accept endpoint missing in backend. Wire accept to /v1 or add controller endpoint.

### Stripe Payments
- **Exists:** payments_api (v1/payments/intent, v1/payments/mine), PayRentScreen. Backend PaymentController /v1/payments (legacy-v1 profile).
- **Wired:** Yes for intent and mine.
- **Blocks release:** Ensure Stripe keys from env (no secrets in repo). Loading/error/success UI and minimal tests.

### Notifications + deep links
- **Exists:** NotificationsScreen (I-10), mock list. Backend GET /v1/notifications.
- **Wired:** No. App does not call GET /v1/notifications.
- **Blocks release:** Wire notifications to API; add deep link parsing and route handling.

---

## 3. Drift and risks

| Risk | Mitigation |
|------|-------------|
| Push blocked by secret | Remove or rotate Stripe key in .env; ensure .env in .gitignore; resolve with GitHub or history rewrite. |
| Path split (/api/v1 vs /v1) | All Flutter calls must use /v1; backend is controller-only. Fix l20, l21, l22, invite_api to /v1. |
| Add Property / Add Unit 404 | Add POST in PropertyController (+ PropertyService); add POST unit in backend if required for MVP. |
| Invite accept missing | Add POST /v1/invites/accept/{token} (or equivalent) in controller. |
| Notifications mock-only | Wire NotificationsScreen to GET /v1/notifications; add deep link handling. |
| Untracked files | Remaining tenant/invite/payments/contractor/guard files: commit MVP-related, ignore or backlog rest. |

---

## 4. Release readiness summary

| Criterion | Ready? |
|----------|--------|
| Build stable (Flutter + Backend) | Yes, after inviteRepoProvider and port fix. |
| Auth (login/register/session) | Yes. |
| Property list | Yes. |
| Add Property | No — backend POST missing; Flutter path /api/v1. |
| Invite create | Yes (inviteRepoProvider). Invite accept: No. |
| Payments (Stripe) | Yes, if env config and UI states in place. |
| Notifications API + deep links | No — not wired. |
| AWS deployable | Not audited; runbook required. |
| iOS/Android store-ready | Not audited; runbooks and checklist required. |

**Verdict:** Repo is not yet release-ready. Priority: fix push block, unify /v1, add property create + invite accept, wire notifications, then AWS + store runbooks and checklists.
