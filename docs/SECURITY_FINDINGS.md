# AYRNOW Security Findings

**Date:** 2026-03-09  
**Scope:** Git/repo, backend, frontend, release config.

---

## 1. Stripe and .env committed in repo and history

| Field | Value |
|-------|--------|
| **Title** | Stripe API keys and backend/.env committed; push blocked |
| **Severity** | Critical |
| **Affected files** | `backend/.env` (tracked in git; present in HEAD). Commit 1f440d0 (and possibly others) in history. |
| **Why it matters** | GitHub push protection blocks push. Exposed Stripe Test Secret Key (sk_test_*) and Publishable Key (pk_test_*) allow abuse of test mode and signal poor secrets hygiene. Any clone or fork can see keys. |
| **Exact fix** | (1) Rotate Stripe Test Secret Key in Stripe Dashboard. (2) Remove `backend/.env` from git: `git rm --cached backend/.env`; add `backend/.env` to `backend/.gitignore` if not already in root `.gitignore` (root already has `backend/.env`). (3) Remove secret from history: either rewrite history to drop `backend/.env` from commit 1f440d0 (and any other commits that add it), or use GitHub’s “Allow secret” once after rotation and ensure .env is never committed again. (4) Ensure no other secrets in .env are committed; use `.env.example` only (no real keys). |
| **Remediation** | **Done on branch `fix/push-secret-and-release-base`:** backend/.gitignore updated; backend/.env untracked; history rewritten with `git filter-branch` so no commit contains backend/.env. **You must still rotate the Stripe Test Secret Key** in Stripe Dashboard (see docs/ENVIRONMENT_VARIABLES.md). |

---

## 2. Production JWT secret not applied

| Field | Value |
|-------|--------|
| **Title** | Prod profile sets auth.jwt.secret but JwtService reads jwt.secret |
| **Severity** | Critical |
| **Affected files** | `backend/src/main/resources/application-prod.yml`, `backend/src/main/java/com/ayrnow/config/JwtProperties.java` |
| **Why it matters** | `JwtProperties` uses `@ConfigurationProperties(prefix = "jwt")` and reads `jwt.secret`. `application-prod.yml` sets `auth.jwt.secret` and `auth.jwt.access-minutes`. StartupValidator checks `auth.jwt.secret`. In prod, `jwt.secret` is never set, so JwtService gets the default from JwtProperties (`change_me_dev_secret`). Tokens can be forged; sessions are insecure. |
| **Exact fix** | In `application-prod.yml` add under the same `auth` or at top level: `jwt.secret: ${JWT_SECRET}` and ensure `JWT_SECRET` is set in prod env. Alternatively, change `JwtProperties` to use prefix `auth.jwt` and align property names (e.g. `secret`, `expirationMinutes`) with application-prod. Prefer one source of truth (e.g. `jwt.secret` everywhere) and have StartupValidator validate the same key the app uses. |

---

## 3. Permissive CORS in production

| Field | Value |
|-------|--------|
| **Title** | CORS allows * by default |
| **Severity** | High |
| **Affected files** | `backend/src/main/resources/application.yml` (`ayrnow.cors.allowed-origins: ${CORS_ALLOWED_ORIGINS:*}`), `backend/src/main/java/com/ayrnow/config/SecurityConfig.java` |
| **Why it matters** | With `*`, any origin can send credentialed requests if combined with permissive credentials. Risk of cross-site abuse and unclear production posture. |
| **Exact fix** | In production (and staging), set `CORS_ALLOWED_ORIGINS` to the exact origin(s) of the Flutter app (e.g. `https://app.ayrnow.com` for web; for mobile, backend often allows any or specific origins depending on architecture). Do not use `*` in prod. Document in ENVIRONMENT_VARIABLES.md. |

---

## 4. Skip login and dev-bypass in release builds

| Field | Value |
|-------|--------|
| **Title** | Dev-only login bypass visible and usable in all builds |
| **Severity** | High |
| **Affected files** | `lib/ui/login_screen.dart` (Skip login button; setting token to `dev-bypass`), `lib/features/landlord/l20_add_property.dart` (accepts token == `dev-bypass`) |
| **Why it matters** | Store reviewers and end users can bypass auth; app appears unfinished and violates store policies. |
| **Exact fix** | Wrap the “Skip login (dev)” control and any code that sets `dev-bypass` in `if (kDebugMode) { ... }` so it is not built or shown in release. In l20_add_property (and any other caller), do not send API requests when token is `dev-bypass` in release; or treat dev-bypass only in debug (e.g. show error or skip API call when token is dev-bypass and not in debug). |

---

## 5. dev-bypass token sent to API

| Field | Value |
|-------|--------|
| **Title** | Add Property flow sends request with dev-bypass token when token is null/empty/dev-bypass |
| **Severity** | Medium |
| **Affected files** | `lib/features/landlord/l20_add_property.dart` (around line 42: `if (token == null || token.isEmpty || token == 'dev-bypass')` then still builds and sends request with that token) |
| **Why it matters** | Backend will reject invalid token; UX is confusing. In release, if dev-bypass is hidden, this path should not run; if it does, we should not send API calls with dev-bypass. |
| **Exact fix** | When token is null, empty, or `dev-bypass`, either: (a) do not call the API and show an error (e.g. “Please sign in”), or (b) in debug only, allow dev-bypass and skip sending Bearer (or send a special header). Prefer (a) for clarity; gate any bypass with kDebugMode. |

---

## 6. Hardcoded JWT default in code

| Field | Value |
|-------|--------|
| **Title** | Default JWT secret in JwtProperties and AuthProperties |
| **Severity** | Medium (mitigated if prod sets env and fix #2 is done) |
| **Affected files** | `backend/src/main/java/com/ayrnow/config/JwtProperties.java` (default `change_me_dev_secret`), `backend/src/main/java/com/ayrnow/config/AuthProperties.java` (default `dev-secret-change-in-production-min-32-chars`) |
| **Why it matters** | If prod config is wrong or env is missing, app could start with dev secret. StartupValidator only runs for staging/prod and checks auth.jwt.secret, not jwt.secret. |
| **Exact fix** | After fixing #2, ensure prod and staging always set `jwt.secret` (or the single source of truth) from env. Optionally have StartupValidator also verify the same property that JwtService uses. Keep defaults only for local/dev profiles. |

---

## 7. PII and logging

| Field | Value |
|-------|--------|
| **Title** | No audit of PII in logs or responses |
| **Severity** | Low (informational) |
| **Affected files** | Backend services and controllers; Flutter app logs |
| **Why it matters** | GDPR/CCPA and store policies may require avoiding logging of passwords, tokens, or unnecessary PII. |
| **Exact fix** | Review backend and frontend logging: ensure no passwords, tokens, or full PII in logs; ensure stack traces and error details are not exposed in prod responses (already partially covered by show-details: when_authorized for actuator). |

---

## 8. Cleartext traffic (mobile)

| Field | Value |
|-------|--------|
| **Title** | API base URL may be http in dev |
| **Severity** | Low for dev; must-fix for prod |
| **Affected files** | `lib/core/backend/api_config.dart`, `lib/core/backend/api_base_url_io.dart` (default localhost:8081 with http) |
| **Why it matters** | Production must use HTTPS. Android may block cleartext by default; iOS requires ATS or exception for http. |
| **Exact fix** | Ensure production API base URL is always HTTPS. Do not ship release build with http base URL. |

---

## Summary table

| # | Title | Severity |
|---|--------|----------|
| 1 | Stripe and .env committed | Critical |
| 2 | Prod JWT secret not applied | Critical |
| 3 | Permissive CORS | High |
| 4 | Skip login in release | High |
| 5 | dev-bypass sent to API | Medium |
| 6 | Hardcoded JWT default | Medium |
| 7 | PII in logs (review) | Low |
| 8 | Cleartext in prod | Low (blocker if used in prod) |
