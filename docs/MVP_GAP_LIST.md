# AYRNOW MVP Gap List

**Date:** 2026-03-09  
**Scope:** Auth, Properties/Units/Leases, Invites/Onboarding, Stripe Payments, Notifications + deep links.  
**Out of scope for MVP:** Contractor, Maintenance (unless blocker).

---

## 1. Build stability

| Gap | Priority | Owner | Action |
|-----|----------|--------|--------|
| Push blocked (Stripe secret in history) | P0 | DevOps/Repo | Resolve per BRANCH_RECOVERY_PLAN.md; then push release branch. |
| Flutter analyze: household inviteRepoProvider | Done | — | Already fixed. |
| Backend build exclusions (api vs controller) | Info | — | No change required; document that only /v1 controller stack is active. |

---

## 2. Auth

| Gap | Priority | Action |
|-----|----------|--------|
| Login/register/me to /v1 | Done | Already wired. |
| Loading/error/success UI on login/register | P2 | Add explicit states and messages. |
| Minimal tests (login/register) | P2 | Add or tag existing AuthControllerTest, AuthFlowIntegrationTest. |
| Token refresh on 401 | P2 | Optional: retry with refresh token before showing error. |

---

## 3. Properties / Units / Leases

| Gap | Priority | Action |
|-----|----------|--------|
| Add Property: Flutter uses POST /api/v1/properties | P0 | Change to POST /v1/properties. |
| Add Property: Backend has no POST /v1/properties | P0 | Add PropertyService.create + @PostMapping in PropertyController; body name + address; owner from auth. |
| l21 Add Unit: uses /api/v1/properties/:id/units | P1 | Change to POST /v1/properties/:id/units (if backend adds it) or document as post-MVP. |
| l22 Property detail: uses /api/v1/properties/:id/units | P1 | Change to GET /v1/properties/:id/units. |
| Loading/empty/error UI on property list and add property | P2 | Verify or add. |
| Minimal tests (property list, create) | P2 | Backend PropertyUnitIntegrationTest; Flutter property tests. |

---

## 4. Invites / Onboarding

| Gap | Priority | Action |
|-----|----------|--------|
| Invite create | Done | inviteRepoProvider POST /v1/units/:id/invites. |
| Invite accept: no backend endpoint in controller | P0 | Add POST /v1/invites/accept/{token} (or equivalent) in controller; wire Flutter. |
| Invite accept: Flutter invite_api uses /api/v1/invites/accept | P1 | Switch to /v1 once backend exists. |
| Loading/error/success UI for invite flows | P2 | Add or verify. |

---

## 5. Stripe Payments

| Gap | Priority | Action |
|-----|----------|--------|
| Payments API (intent, mine) | Done | v1/payments. |
| Stripe keys from env only | P0 | No keys in repo; ENVIRONMENT_VARIABLES.md. |
| Loading/error/success UI on pay rent | P2 | Verify. |
| Webhook URL for production | P1 | Document in AWS runbook; configure in Stripe dashboard. |

---

## 6. Notifications + deep links

| Gap | Priority | Action |
|-----|----------|--------|
| NotificationsScreen uses mock list | P0 | Wire to GET /v1/notifications; loading/empty/error. |
| Deep link parsing and routing | P1 | Parse notification payload; navigate to correct route. |
| Backend GET /v1/notifications | Exists | — |

---

## 7. AWS deploy readiness

| Gap | Priority | Action |
|-----|----------|--------|
| Runbook | P0 | Create AWS_DEPLOYMENT_RUNBOOK.md (no Docker). |
| Env and secrets | P0 | ENVIRONMENT_VARIABLES.md; RDS, JWT, Stripe. |
| Health and port | P1 | Backend /api/v1/health or /v1/health; document port. |

---

## 8. iOS/Android store readiness

| Gap | Priority | Action |
|-----|----------|--------|
| MOBILE_RELEASE_RUNBOOK.md | P0 | Build variants, signing, versioning. |
| STORE_SUBMISSION_CHECKLIST.md | P0 | App Store + Google Play steps. |
| API base URL for production | P1 | App points to production backend URL; no hardcoded localhost in release. |

---

## 9. Summary: P0 blockers

1. Resolve push block (secret in history).  
2. Add Property: backend POST /v1/properties + Flutter to /v1.  
3. Invite accept: backend endpoint + Flutter to /v1.  
4. Notifications: wire app to GET /v1/notifications.  
5. Stripe and all secrets from env only; document in ENVIRONMENT_VARIABLES.md.  
6. AWS and store runbooks and checklists.
