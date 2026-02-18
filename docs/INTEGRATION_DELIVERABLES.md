# AYRNOW Real-Backend Integration — Deliverables

## 1. Progress Checklist

| Phase | Status | Notes |
|-------|--------|-------|
| **0 Stabilize** | ✅ Done | FeatureFlags.allReal; RenderFlex overflow fix (Row→Wrap); Reset app state in ⋮ menu |
| **1 Auth** | ✅ Done | JWT login/register/refresh/logout via AuthController; no mock auth; secure token storage |
| **2 Properties/Units/Leases** | ✅ Done | List/create properties; list/create units; tenant context from /leases/me/active |
| **3 Invites** | ✅ Done | Create invite (email/phone); accept via token; InviteLandingScreen, InviteAcceptScreen, InviteByCodeScreen |
| **4 Community** | 🔲 Pending | Backend ready (posts/comments/reactions). Flutter still uses mock store. |
| **5 Payments** | 🔲 Pending | Backend ready (Stripe checkout, webhook). Flutter still uses mock. |
| **6 Documents** | ✅ Done | Backend: generate, download, accept. Flutter: DocumentsApi, AiApi clients. |
| **7 AI Lease Draft** | ✅ Done | Backend: POST /api/v1/ai/lease-draft stub. Flutter: AiApi client. |

---

## 2. Exact Run Instructions

### Backend

```bash
cd backend
./scripts/run_local.sh
```

Verify: `curl -s http://127.0.0.1:8080/api/v1/health` → `{"status":"ok"}`

If DB needs reset (missing test user):

```bash
# Stop backend first
cd backend
./scripts/reset_local_db.sh
./scripts/run_local.sh
```

### Flutter

```bash
# From project root
./scripts/run_simulator.sh
```

Or:

```bash
flutter run -d "iPhone 17 Pro"
```

---

## 3. Endpoints Added on Backend

| File | Endpoints |
|------|-----------|
| `backend/src/main/java/com/ayrnow/api/DocumentController.java` | `POST /api/v1/documents/leases/{leaseId}/generate`, `GET /api/v1/documents/{documentId}/download`, `POST /api/v1/documents/{documentId}/accept` |
| `backend/src/main/java/com/ayrnow/api/AiLeaseController.java` | `POST /api/v1/ai/lease-draft` |

All other endpoints (auth, properties, units, leases, invites, tickets, posts, payments) existed in the backend already.

---

## 4. Happy Path Walkthrough (App No Longer Mock-Based)

1. **Start backend** (`./backend/scripts/run_local.sh`), verify health.
2. **Start app** (`./scripts/run_simulator.sh`).
3. **Login** — Use "Use test account" (test@test.com / test123) → Landlord dashboard.
4. **Properties** — Empty list or existing. Tap FAB → Add property → Name + City → Save → List refreshes from API.
5. **Units** — Tap property → Unit list. Tap FAB → Add unit (e.g. "101") → Unit created via API.
6. **Invite** — Tap unit → Overview → Invite → Enter email → Send invite. Creates via `POST /api/v1/units/{unitId}/invites`.
7. **Accept invite** — (As tenant) Enter invite token from link → Accept → `POST /api/v1/invites/accept/{token}`.
8. **Tenant context** — Tenant login uses `/leases/me/active` + unit fetch to set property/unit context.
9. **Reset** — ⋮ menu → "Reset app state" (debug) → Clears tokens and caches.

All of the above use real JWT auth and backend APIs. No mock data on these flows.

---

## Branch + Commits

- Branch: `feature/integration-real-backend`
- Commits:
  - `feat(auth): JWT login/register/refresh, remove mock auth`
  - `feat(properties): wire properties/units API, add lease context for tenants`
  - `feat(invites): wire invite flow to backend API`
  - `feat(documents,ai): backend stubs + Flutter API clients`
