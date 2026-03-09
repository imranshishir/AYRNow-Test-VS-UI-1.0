# AYRNOW Recovery Durability Status

**Date:** 2026-03-09  
**Branch:** fix/restore-register-and-property-nav  

---

## A. RECOVERY DURABILITY STATUS

| Item | Status |
|------|--------|
| **Current branch** | fix/restore-register-and-property-nav |
| **Git status summary** | 2 commits ahead (Register link, Add Property nav + providers). Working tree dirty: 10 modified tracked (ios/linux/macos/windows Flutter configs, codenexas). 50+ untracked files (auth, common, landlord, tenant, contractor, guard, investor, invite, payments, dtos, docs, scripts, tests, backend OAuth/seed, build artifacts). |
| **What is still fragile** | (1) All recovered screens (Register, Add Property, Property List, etc.) and shared dtos are **untracked** — clone/fresh checkout loses them. (2) Register is **visible but not functional** (demo delay only; no API call). (3) Add Property calls **/api/v1/properties** but active backend has **no POST** — only GET /v1/properties; create will 404. (4) routes.dart and main.dart reference features/auth and features/landlord screens that exist only on disk. |
| **Shareable yet?** | **No.** Until essential untracked files are committed, the recovery is not durable or shareable. |

---

## B. ESSENTIAL UNTRACKED FILES TABLE

| Path | Purpose | Needed now? | Category | Commit now / later / ignore |
|------|---------|-------------|----------|-----------------------------|
| lib/features/auth/register_screen.dart | Register UI, /register route | Yes | Auth flow | **Commit now** |
| lib/features/auth/login_screen.dart | Login variant in routes | Yes | Auth flow | **Commit now** |
| lib/features/auth/forgot_password_screen.dart | Forgot password, routes | Yes | Auth flow | **Commit now** |
| lib/features/landlord/l20_add_property.dart | Add Property screen | Yes | Landlord property | **Commit now** |
| lib/features/landlord/l21_add_unit.dart | Add Unit screen | Yes | Landlord property | **Commit now** |
| lib/features/landlord/l22_property_detail.dart | Property detail | Yes | Landlord property | **Commit now** |
| lib/features/landlord/l25_property_list.dart | Property list | Yes | Landlord property | **Commit now** |
| lib/core/backend/dtos/property_dto.dart | Property list DTO, providers | Yes | Shared | **Commit now** |
| lib/core/backend/dtos/unit_dto.dart | Add unit response, l21 | Yes | Shared | **Commit now** |
| lib/features/common/profile_screen.dart | /profile route | Yes | Common | **Commit now** |
| lib/features/common/notifications_screen.dart | /I-10 route | Yes | Common | **Commit now** |
| lib/features/common/settings_screen.dart | /A-20 route | Yes | Common | **Commit now** |
| lib/features/common/help_screen.dart | /help route | Yes | Common | **Commit now** |
| lib/features/tenant/t06_dashboard.dart | Tenant home | Yes | Tenant | Commit later |
| lib/features/tenant/t07_lease_view.dart … t23 | Tenant screens | Later | Tenant | Commit later |
| lib/features/invite/*, invite_accept/* | Invite flow | Later | Invite | Commit later |
| lib/features/payments/* | Payments | Later | Payments | Commit later |
| docs/MVP_AUDIT_REPORT.md, RECOVERY_REPORT.md | Audit docs | Yes | Docs | Commit now |
| .flutter-plugins-dependencies | Flutter generated | No | Junk | **Ignore** |
| backend/Gen.java | Generated | No | Junk | **Ignore** |
| ios/Podfile, Podfile.lock, macos/Podfile | Platform deps | Optional | Build | Ignore or later |
| scripts/run_*.sh | Dev scripts | Later | Scripts | Commit later |
| test/*_test.dart | Tests | Later | Tests | Commit later |
| backend OAuth/DevLogin (AppleLogin, GoogleLogin, DevLoginSeeder, V25) | Backend extras | Later | Backend | Commit later or ignore |
| contractor, guard, investor feature files | Non-MVP | No | Other | Ignore for this pass |

---

## C. SCREEN AND ROUTE STATUS TABLE

| Screen | File | Route | Reachable? | Entry point | Backend dependency | Working / partial / broken | Recovery action |
|--------|------|--------|------------|-------------|--------------------|----------------------------|-----------------|
| Login | lib/ui/login_screen.dart | /login | Yes | AuthGate, main | POST /v1/auth/login | Working | — |
| Register | lib/features/auth/register_screen.dart | /register | Yes | Login “Register” link | POST /v1/auth/register | **Partial** (no API) | Wire submit to API |
| Landlord dashboard | lib/features/landlord/l12_dashboard.dart | /L-12 | Yes | AppShell tab 0 | Mock rent/tickets | Working | — |
| Property list | lib/features/landlord/l25_property_list.dart | /L-25 | Yes | Dashboard “My Properties” | GET /v1/properties | **Working** (provider wired) | — |
| Add property | lib/features/landlord/l20_add_property.dart | /L-20 | Yes | Dashboard “Add Property” | POST (none in controller) | **Broken** (404) | Add backend create or /v1 POST |
| Property detail | lib/features/landlord/l22_property_detail.dart | /L-22 | From L-25 | L-25 list tap | GET /v1/properties/:id/units | Partial | — |
| Add unit | lib/features/landlord/l21_add_unit.dart | /L-21 | From L-22 | L-22 | POST (api excluded) | Partial/broken | Later |

---

## D. REGISTER FLOW TRUTH

| Question | Answer |
|----------|--------|
| **Visible?** | Yes. Login has “Register” link → /register → RegisterScreen. |
| **Functional?** | **No.** _register() does a 700ms delay and “Account created successfully (demo)” then navigates to /home. No HTTP call. |
| **Exact blockers** | (1) No call to POST /v1/auth/register. (2) No token/session set after register (backend returns LoginResponse with token). (3) Backend expects: email, password, role, name (optional). Flutter has name, email, phone, password, confirm, role — phone not in API, can omit. |
| **Next fix** | Wire RegisterScreen: on submit call POST /v1/auth/register with email, password, role (UserRole.name), name; on success parse token/user, persist token, set authTokenProvider + currentUserProvider, navigate to /home. Handle 4xx and network errors. |

---

## E. PROPERTY FLOW TRUTH

| Question | Answer |
|----------|--------|
| **My Properties visible?** | Yes. Dashboard “My Properties” → /L-25. |
| **My Properties functional?** | **Yes.** landlordPropertiesProvider calls GET /v1/properties; loading/empty/error and list UI exist. |
| **Add Property visible?** | Yes. Dashboard “Add Property” → /L-20. |
| **Add Property functional?** | **No.** Screen calls POST $baseUrl/api/v1/properties. Active backend has **no POST** — PropertyController only has GET and GET listUnits. Create lives in excluded api package. Result: 404. |
| **Exact blockers** | (1) Backend controller has no POST /v1/properties. (2) Frontend uses /api/v1/properties; even if backend had create, path would need to be /v1/properties for current build. |
| **Next fix** | (1) Add POST /v1/properties to PropertyController + PropertyService.create(ownerUserId, name, address). (2) In Flutter change l20 to POST /v1/properties and align body with backend DTO (e.g. name, address). |

---

## F. BACKEND GAP SUMMARY

| What exists | What is missing | Smallest backend change now |
|-------------|-----------------|------------------------------|
| POST /v1/auth/register, login, refresh | — | None for auth. |
| GET /v1/properties, GET /v1/properties/{id}/units | POST /v1/properties (create) | Add create in PropertyService; add @PostMapping in PropertyController; accept name + address (or address1/city/state/postalCode); set ownerUserId from auth. |

---

## G. SMALL-BRANCH EXECUTION PLAN

| Step | Branch | Objective | Files | Action | Verification | Commit message | Merge criteria |
|------|--------|-----------|--------|--------|--------------|----------------|----------------|
| 1 | (current) | Make recovery durable | auth/, common/, landlord l20–l25, dtos, docs | Add and commit only essential untracked files for auth, common, landlord property, dtos, recovery docs | flutter analyze; app opens; login → register → screen; landlord → My Properties / Add Property | chore(recovery): add recovered auth, common, and landlord property screens + dtos | No new analyzer errors; routes resolve. |
| 2 | fix/register-wire-api | Register functional | lib/features/auth/register_screen.dart | Call POST /v1/auth/register; parse token; set auth state; navigate to /home; error handling | Register form → 201 → home with session | fix(auth): wire register to POST /v1/auth/register | Register creates account and logs in. |
| 3 | fix/add-property-backend-and-client | Add Property functional | backend PropertyController, PropertyService; lib/features/landlord/l20_add_property.dart | Backend: POST /v1/properties. Flutter: POST /v1/properties, body match | Add property → 201 → list shows new | fix(properties): add POST /v1/properties and wire Add Property screen | Create property succeeds. |

---

## H. FIRST SAFE STEP

**Execute Step 1:** Commit essential untracked files on current branch so the recovery is durable and shareable. No behavior change; only track the files that routes and providers already depend on.
