# AYRNOW Branch Recovery Plan

**Date:** 2026-03-09  
**Goal:** Single stable release branch, no Docker, small PRs.

---

## 1. Recommended release base

| Branch | Recommendation | Reason |
|--------|----------------|--------|
| **fix/restore-register-and-property-nav** | **Use as release base** | Has recovery (Register, Add Property nav, auth/register wired to /v1, durable screens, inviteRepoProvider, port 8081, Skip login dev). Most complete MVP-facing branch. |
| release/mvp-integration | Merge into or from fix/restore-* after push unblocked | Older integration branch; fix/restore-* is ahead with recovery. |
| main | Behind | Does not have auth gate, /v1 wiring, or recovered screens. |
| fix/api-path-v1 | Already merged into fix/restore-* lineage | Auth/me use /v1. |

**Action:** Treat **fix/restore-register-and-property-nav** as the release branch. Rename to **release/mvp-ship** (or keep name) after resolving push block. All stabilization and MVP work branches should target this branch.

---

## 2. Branch strategy

- **One release branch:** fix/restore-register-and-property-nav (or release/mvp-ship).
- **Small scoped branches** from it: fix/*, feature/*, chore/*. One logical change per branch; merge back after verification.
- **No direct commits to main** for MVP; merge release branch when ready.
- **Contractor/Maintenance/Investor/Guard** features stay on feature branches until post-MVP.

---

## 3. Push block resolution (required first)

GitHub rejected push: **Stripe Test API Secret Key** in commit 1f440d0 (backend/.env).

Options (pick one):

1. **Allow secret (temporary):** Use GitHub’s “allow secret” link from the push error to unblock once (not recommended for production key).
2. **Remove from history:** Ensure backend/.env is in .gitignore; remove .env from all commits (e.g. git filter-branch or BFG); force-push. Then set secrets in CI/env only.
3. **New branch from clean state:** Create a new branch from main or from before 1f440d0; cherry-pick or re-apply only commits that do not add .env; push new branch.

After push is possible, continue with implementation branches below.

---

## 4. Merge order (into release base)

1. Resolve push block.
2. fix/property-create-and-paths — Add Property POST + /v1 paths for l20, l21, l22.
3. fix/invite-accept — Backend invite accept + Flutter to /v1.
4. feature/notifications-wire — GET /v1/notifications + deep links.
5. chore/aws-and-store-docs — Runbooks and checklists (no code dependency).
6. fix/stability — Any remaining build/runtime fixes and tests.
7. Merge release branch to main when MVP + deploy + store readiness are done.

---

## 5. What not to merge

- Branches that re-add Docker to local workflow.
- Broad UI redesigns or new architecture.
- Contractor/Maintenance as MVP scope (unless needed to unblock).
- Commits that re-introduce secrets in repo.
