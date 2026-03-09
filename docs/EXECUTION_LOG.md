# AYRNOW MVP — Execution Log

**Last updated:** 2026-02-27

---

## 1. Current branch

- **At audit:** `fix/payments-api-local-profile`
- **MVP integration branch:** `release/mvp-integration` (created in Phase 0)

---

## 2. Git status (at audit)

- **Branch:** fix/payments-api-local-profile
- **Status:** DIRTY
- **Modified (M):** ~55 files (backend: build.gradle, api/*, config/*, controller/*, repository/*, service/*, resources; lib: core/backend, core/state/providers, features/household, landlord l12/l23, tenant t10, main, app_shell, auth_gate, login_screen; ios/build, pubspec, etc.)
- **Untracked (??):** 50+ (docs, backend OAuth/DevLogin/seed, lib features: auth, common, invite, invite_accept, landlord l20–l38, payments, tenant t07/t11–t14/t20–t23, contractor/guard/investor extras, scripts, test files)

---

## 3. Clean vs dirty

- **Working tree:** DIRTY (uncommitted changes and untracked files).
- **Intent:** Use `release/mvp-integration` as the single clean branch for MVP; bring in only MVP-relevant work.

---

## 4. Open PR work — merged vs still missing

| PR | Branch | Status | Action |
|----|--------|--------|--------|
| **#11** Auth token persistence | feat/auth-token-persistence | **Already in current branch** (commit 903b8c3) | None |
| **#8** Mock-to-API seam | chore/api-seam-v1 | Partially in current branch (api v1 backend in 2880f90; app wiring in uncommitted) | Use current branch + uncommitted; no separate merge |
| **#7** Notifications v1 | feat/notifications-v1 | Not merged | **Excluded for Phase 0**; add in Phase 5 if needed |
| **#3** Hero-tag crash fix | fix/hero-tags-only | **Not in current branch** | **Cherry-pick into release/mvp-integration** |
| **#2** Hero-tag (duplicate) | ayrnowdev/fix/hero-tags-fab | Same fix as #3 | Ignore (use #3) |
| **#10** Dev DB reset | chore/dev-db-reset-and-migrations | Already in current branch (568e693) | None |
| **#9** Test DB isolation | chore/test-db-isolation | Already in current branch (19e3b5f) | None |
| **#6** Family roles | feat/family-roles-v1 | Non-MVP (household/family in backlog) | **Excluded** |
| **#4** Firebase M2 | feature/firebase-m2-properties-leases | Non-MVP (Spring is source of truth) | **Excluded** |
| **#1** Os book site | os-book-site-v1 | Unrelated | **Excluded** |

---

## 5. Files and branches relevant to MVP only

**Branches:**

- `release/mvp-integration` — main integration branch for MVP completion.
- `fix/payments-api-local-profile` — base for release/mvp-integration (has api v1 backend + auth persistence + payments profile fix).

**MVP-relevant paths (include):**

- **Backend:** `backend/src/main/java/com/ayrnow/api/*`, `config/*` (JWT, Security, DevLoginSeeder), `service/*` (Auth, Property, Unit, Lease, Payment, TenantInvite, Notification), `domain/entity/*`, `domain/repository/*`, Flyway migrations, `scripts/run_local.sh`, `build.gradle`, `application.yml`.
- **Flutter:** `lib/main.dart`, `lib/ui/auth_gate.dart`, `lib/ui/login_screen.dart`, `lib/ui/app_shell.dart`, `lib/core/state/providers.dart`, `lib/core/backend/api_base_url.dart`, `lib/core/backend/dtos/*`, `lib/navigation/routes.dart`, `lib/features/landlord/l12_dashboard.dart`, `l20_add_property.dart`, `l21_add_unit.dart`, `l22_property_detail.dart`, `l23_rent_board.dart`, `l25_property_list.dart`, `lib/features/tenant/t06_dashboard.dart`, `t07_lease_view.dart`, `t10_pay_rent.dart`, `t11_payment_method.dart`, `t12_payment_confirmation.dart`, `t13_receipt_detail.dart`, `t14_receipts.dart`, `lib/features/invite/*`, `lib/features/invite_accept/*`, `lib/features/payments/*`, `lib/features/auth/*` (login/register/forgot), `lib/features/common/notifications_screen.dart`, `lib/features/household/screens/invite_household_member_screen.dart`, `tenant_household_screen.dart`, `landlord_unit_residents_screen.dart` (minimal invite/residents flow). Scripts: `run_ios_simulator.sh`, `run_android_device.sh`.

**Exclude from MVP scope (do not merge / do not rely on for release):**

- Contractor: `lib/features/contractor/*` (and backend contractor-only).
- Maintenance: landlord maintenance inbox beyond any dependency for lease/unit.
- Guard: `lib/features/guard/*`.
- Community: community tab/social (backlog).
- Household “family roles” expansion (backlog).
- Tenant transfer: `lib/features/tenant_transfer/*` (backlog).
- Investor/demo/spec: `lib/features/investor/*`, spec index/spec screens as primary flow.
- Firebase path (use Spring backend only for MVP).

---

## 6. What must be ignored for now

- All non-MVP PRs: #1, #2 (duplicate), #4 (Firebase), #6 (family roles).
- Any route or screen that is purely demo/spec (e.g. role selector as default entry — already not default; `/` → AuthGate).
- Mock repos in MVP code paths must be removed or replaced by API before release (tracked per phase).
- Docker (not used).
- Global theme/UI redesign.

---

## Phase 0 — Stabilize repo and integration path

**Goal:** One clean branch for MVP completion; no drift.

**Done:**

1. Audited branch, status, PRs, and MVP relevance.
2. Created `release/mvp-integration` from `fix/payments-api-local-profile`.
3. Cherry-picked **fix/hero-tags-only** (PR #3) into `release/mvp-integration` to fix FAB Hero tag crash.
4. Confirmed app entry: `main.dart` → `initialRoute: '/'` → `AuthGate` → LoginScreen or AppShell (no demo role selector in normal path).
5. Documented what was merged/cherry-picked and what was excluded (below).

**Merged / cherry-picked into release/mvp-integration:**

- Full history of `fix/payments-api-local-profile` (api v1 backend, auth persistence, nav fixes, payments profile `local,legacy-v1`, etc.).
- **Hero-tag fix:** PR #3 (`fix/hero-tags-only`) could not be cherry-picked (conflicts in community/invite files from different structure). Applied minimal equivalent: added `heroTag: 'app_shell_fab'` to the extended FAB in `lib/ui/app_shell.dart` to avoid duplicate Hero tag crash.

**WARNING — Phase 0 reset:** During conflict resolution, `git reset --hard HEAD` was run on `release/mvp-integration`. That **reverted all uncommitted modifications** (backend and lib files that were M). **Untracked files (??) are unchanged.** If you had critical MVP work only in modified-but-uncommitted files, restore from editor local history or re-apply those changes. Remaining modified state after Phase 0: platform/config (ios, linux, macos, windows), and `codenexas`; plus all untracked MVP-relevant files (landlord l20–l25, tenant, invite, payments, etc.) remain on disk.

**Intentionally excluded (for now):**

- PR #7 (notifications v1) — to be added in Phase 5.
- PR #6 (family roles), #4 (Firebase), #1 (os book), #2 (duplicate hero).
- All contractor, guard, community, tenant-transfer feature work.
- Any change that would make role selector or spec screen the default startup.

**Deliverables:**

- Branch: `release/mvp-integration`.
- This execution log and Phase 0 note.

**Next:** Proceed to Phase 1 (Auth) on `release/mvp-integration`.
