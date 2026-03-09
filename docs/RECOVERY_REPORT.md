# AYRNOW UI/Flow Recovery Report

**Date:** 2026-03-09  
**Branch:** fix/api-path-v1 (then recovery branches)  
**Goal:** Restore Register, Add Property, and core landlord flows without rebuilding.

---

## A. CURRENT APP STATE

| Item | Status |
|------|--------|
| **Current branch** | fix/api-path-v1 |
| **Working tree** | Dirty (modified + many untracked). Uncommitted: ios/macos/linux/windows Flutter configs, lib/core/state/providers.dart, lib/main.dart, lib/ui/*. Untracked: lib/features/auth/, common/, landlord l20–l38, tenant t07–t23, invite, payments, etc. |
| **App entry** | main.dart → `/` = AuthGate → (token valid) AppShell, else LoginScreen. `/login` and `/home` explicit in main. buildRoutes() merged in. |
| **Login screen in use** | **lib/ui/login_screen.dart** (set in main.dart for `/login`). No link to Register. |
| **Landlord home** | AppShell tab 0 → LandlordDashboardScreen (l12). No link to Property List (L-25) or Add Property (L-20). |
| **Drift assessment** | **Recoverable.** Register and Add Property screens and routes exist (in routes.dart and in untracked/feature files). They are **disconnected** from the visible UI: (1) Login has no “Register” link, (2) Landlord dashboard has no “My Properties” or “Add Property” entry. Main branch has a different entry (RoleSelectorScreen, no auth) and fewer routes (no /login, /register, L-20, L-25). |
| **Start from scratch?** | **No.** Screens and routes exist; restoration is wiring + navigation only. |

---

## B. MISSING OR DISCONNECTED CORE FLOWS

| Flow | In current branch | In another branch | Disconnected from routing | Blocked by backend | Notes |
|------|-------------------|-------------------|---------------------------|--------------------|-------|
| **Register** | Screen: lib/features/auth/register_screen.dart. Route: /register, /L-02, etc. in buildRoutes(). | N/A | **Yes.** lib/ui/login_screen.dart (the one shown) has no “Register” link. | No. Backend has POST /v1/auth/register. | Restore: add “Don’t have an account? Register” on ui/login_screen.dart → /register. |
| **Add Property** | Screen: lib/features/landlord/l20_add_property.dart. Route: /L-20 in buildRoutes(). | N/A | **Yes.** Landlord dashboard (l12) has no “My Properties” or “Add Property” link. FAB goes to L-30 (tickets). | Partial. Controller has GET /v1/properties only; create is in excluded api. l20 calls /api/v1/properties. | Restore: add “My Properties” and “Add Property” to l12; fix l20 to /v1 if/when backend has create. |
| **Property List** | Screen: l25_property_list.dart. Route: /L-25. | N/A | **Yes.** No link from landlord dashboard to L-25. | Backend has GET /v1/properties. | Restore: add “My Properties” card/button on l12 → /L-25. |
| **Unit/Lease flow** | L-21 Add Unit, L-22 Property Detail, L-24 Unit Detail in routes. | N/A | L-25 and L-22 can navigate to L-21/L-24 once L-25 is reachable. | List/units under /v1. Create in excluded api. | Restore L-25 first; then flow is reachable. |
| **Invite flow** | invite_api, invite_accept_screen, routes. | N/A | Reachable from L-50 (Residents) which is on l12. | Create at /v1/units/{id}/invites; accept only in excluded api. | OK for create; accept may need backend. |
| **Payments** | t10, payments_api, /v1/payments. | N/A | Reachable via Pay tab and FAB (tenant). | Backend has /v1/payments. | Wired. |
| **Notifications** | NotificationsScreen at /I-10. | N/A | Reachable via app bar icon. | Mock list; backend has /v1/notifications. | Backlog: wire API. |

---

## C. SCREEN / ROUTE RECOVERY TABLE

| Screen | File | Route | Reachable? | Expected entry | What’s broken | Recovery action |
|--------|------|--------|------------|----------------|---------------|-----------------|
| Login | lib/ui/login_screen.dart | /login | Yes (AuthGate, /) | AuthGate → LoginScreen | No Register link | Add “Don’t have an account? Register” → /register |
| Register | lib/features/auth/register_screen.dart | /register, /L-02, … | **No** | From login | No link from login | Add link on login (above) |
| Landlord dashboard | lib/features/landlord/l12_dashboard.dart | /L-12 | Yes (AppShell tab 0) | AppShell | No Properties / Add Property | Add “My Properties” → /L-25, “Add Property” → /L-20 |
| Add Property | lib/features/landlord/l20_add_property.dart | /L-20 | **No** | From dashboard or L-25 | No link from dashboard; l20 uses landlordPropertiesRefreshProvider (missing) | Add link on l12; add provider in providers.dart |
| Property List | lib/features/landlord/l25_property_list.dart | /L-25 | **No** | From dashboard | No link from dashboard | Add “My Properties” on l12 → /L-25 |
| Property Detail | l22_property_detail.dart | /L-22 | From L-25 | L-25 list | — | Ensure L-25 links to L-22 |
| Add Unit | l21_add_unit.dart | /L-21 | From L-22 | L-22 | — | — |
| Rent Board | l23_rent_board.dart | /L-23 | Yes (l12) | l12 quick action | — | — |
| Maintenance | l30, L-31, L-33 | /L-30, … | Yes (l12, FAB) | l12, FAB | — | — |

---

## D. BRANCH RECOVERY FINDINGS

| Branch | Missing UI pieces | Missing backend | Cherry-pick / merge | Ignore | Note |
|--------|--------------------|-----------------|---------------------|--------|------|
| **main** | Login/Register as auth flow; L-20, L-25, L-22, L-21; auth screens in routes. Entry is RoleSelectorScreen. | N/A | Do not merge main into current; current has more. | — | main is behind; current branch has the screens, just disconnected. |
| **release/mvp-integration** | Same as current (routes and screens present). | N/A | Merge fix/api-path-v1 and recovery branches into release/mvp-integration. | — | Integration branch. |
| **finish/m1a-landlord-real-flow** | Stash has “wip before new module integration”. | — | Optional: review stash for landlord flow. | — | Stash only. |
| **v1.1-landlord-unit-tabs-hifi** | Possible landlord/unit UI. | — | Optional: compare l12/l25 if needed. | — | — |

**Safest path:** Stay on current branch (or release/mvp-integration). Restore flows by (1) adding Register link on login, (2) adding My Properties and Add Property on landlord dashboard, (3) adding landlordPropertiesRefreshProvider so L-20 doesn’t crash. No need to cherry-pick from other branches for Register or Add Property; they exist in tree.

---

## E. RECOMMENDED FIX PLAN

| Step | Branch | Objective | Files | Action | Verification | Merge criteria |
|------|--------|-----------|-------|--------|--------------|----------------|
| 1 | fix/restore-register-link | Register visible from login | lib/ui/login_screen.dart | Add “Don’t have an account? Register” TextButton → Navigator.pushNamed(context, '/register'). | Open app → Login → see Register link → tap → Register screen. | Register screen opens from login. |
| 2 | fix/restore-add-property-nav | Add Property + Property List reachable | lib/features/landlord/l12_dashboard.dart, lib/core/state/providers.dart | On l12 add “My Properties” (→ /L-25) and “Add Property” (→ /L-20). Add landlordPropertiesRefreshProvider in providers.dart. | Login as landlord → Home → see My Properties & Add Property → tap L-25 and L-20. | Both screens open from dashboard. |
| 3 | (optional) fix/register-wire-backend | Register calls API | lib/features/auth/register_screen.dart | Call POST /v1/auth/register then navigate to /home or login. | Register form submits → 201 → home. | Register creates account. |
| 4 | (optional) fix/add-property-api-path | L-20 create uses /v1 | lib/features/landlord/l20_add_property.dart | When backend has create: use /v1/properties or add create in controller. | Add property form → 201. | Out of scope if backend has no create. |

---

## F. FIRST ACTIONS TAKEN

1. **fix/restore-register-link**  
   - In lib/ui/login_screen.dart: add a “Don’t have an account? Register” link that navigates to `/register`.  
   - Verification: Run app → Login screen → tap Register → Register screen.

2. **fix/restore-add-property-nav**  
   - In lib/features/landlord/l12_dashboard.dart: add “My Properties” and “Add Property” to the first section (or quick actions) linking to `/L-25` and `/L-20`.  
   - In lib/core/state/providers.dart: add `landlordPropertiesRefreshProvider` (e.g. StateProvider<int>) so L-20 can trigger list refresh.  
   - Verification: Login as landlord → see My Properties and Add Property → open L-25 and L-20.

These two steps restore the original intended entry points for Register and Add Property without redesign or new architecture.
