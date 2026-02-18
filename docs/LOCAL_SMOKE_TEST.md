# AYRNOW Local Smoke Test Guide

Run these steps to verify the app works end-to-end with the Spring Boot backend.

## Prerequisites
- Backend running on `http://127.0.0.1:8080`
- PostgreSQL with Flyway migrations applied
- Flutter iOS simulator (iPhone 17 Pro recommended)

## 1. Start Backend

```bash
cd backend
./scripts/run_local.sh
```

Verify: `curl -s http://127.0.0.1:8080/api/v1/health` returns `{"status":"ok"}`.

## 2. Reset Local DB (if needed)

If test user is missing or DB is corrupted:

```bash
# Stop the backend first, then:
cd backend
./scripts/reset_local_db.sh
./scripts/run_local.sh
```

## 3. Run Flutter App

```bash
# From project root
./scripts/run_simulator.sh
```

Or:

```bash
flutter run -d "iPhone 17 Pro"
```

## 4. Smoke Test Checklist

| Step | Action | Expected |
|------|--------|----------|
| 1 | Open app | Login screen |
| 2 | Use "Use test account" (fills test@test.com / test123) | Landlord dashboard |
| 3 | Or register new account (Landlord role) | Confirmation → Dashboard |
| 4 | Properties list | Empty or existing properties |
| 5 | Add property (tap FAB) | Property created, list refreshes |
| 6 | Tap property | Unit list (empty or existing) |
| 7 | Add unit (tap FAB) | Unit created |
| 8 | Tap unit | Unit tabs (Rent, Maintenance, Documents, etc.) |
| 9 | Switch role (⋮ menu → Switch role) | Role selection → back to login |

## 5. Tenant Flow (requires invite + lease)

1. Register as Landlord, create property + unit
2. Invite tenant to unit (Phase B4)
3. Accept invite (deep link or code)
4. Create lease for unit ( landlord flow )
5. Login as tenant → should see active lease context

## 6. Community (Phase B7)

- Posts: List, create, comment, react (backend ready; Flutter wiring in progress)
- Notifications: List, mark read

## 7. Payments (Phase B10)

- Create Stripe checkout session: `POST /api/v1/payments/stripe/checkout-session`
- Use Stripe CLI for local webhook: `stripe listen --forward-to localhost:8080/api/v1/payments/stripe/webhook`

## 8. Documents (Phase 6)

- Generate: `POST /api/v1/documents/leases/{leaseId}/generate` → documentId, downloadUrl
- Download: `GET /api/v1/documents/{documentId}/download`
- Accept: `POST /api/v1/documents/{documentId}/accept` with `{typedName, acceptedAt}`

## 9. AI Lease Draft (Phase 7)

- `POST /api/v1/ai/lease-draft` with propertyId, unitId, leaseId → deterministic stub draft

## Troubleshooting

| Issue | Fix |
|-------|-----|
| 401 on API calls | Ensure logged in; use test@test.com / test123 or register |
| Connection refused | Start backend: `./backend/scripts/run_local.sh` |
| Empty properties | Normal for new account; add via FAB |
| Flyway version conflict | Run `./backend/scripts/check_flyway_versions.sh` |
| Reset app state | ⋮ menu → "Reset app state" (debug builds only) |

## API Base URL

Default: `http://127.0.0.1:8080` (iOS simulator). Override with:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8080
```

## Progress Checklist (feature/integration-real-backend)

| Phase | Status | Notes |
|-------|--------|-------|
| 0 Stabilize | ✅ | FeatureFlags.allReal, RenderFlex fix, Reset app state |
| 1 Auth | ✅ | JWT login/register/refresh/logout, no mock auth |
| 2 Properties/Units/Leases | ✅ | List, create, empty state; tenant context from /leases/me/active |
| 3 Invites | ✅ | Create, accept via token; InviteLandingScreen, InviteAcceptScreen |
| 4 Community | 🔲 | Backend ready; Flutter wires mock (future work) |
| 5 Payments | 🔲 | Backend ready; Flutter wires mock (future work) |
| 6 Documents | ✅ | Backend: generate, download, accept. Flutter: DocumentsApi, AiApi |
| 7 AI Lease Draft | ✅ | Backend: POST /api/v1/ai/lease-draft stub |

## New Backend Endpoints Added

| File | Endpoint |
|------|----------|
| `api/DocumentController.java` | POST /documents/leases/{leaseId}/generate, GET /documents/{id}/download, POST /documents/{id}/accept |
| `api/AiLeaseController.java` | POST /ai/lease-draft |
