# AYRNOW Environment Variables

**Never commit secrets to the repo.** Use local .env (gitignored), CI secrets, or AWS Parameter Store / Secrets Manager.

---

## Secret rotation requirement (one-time)

**If you pulled or cloned this repo before the push-secret fix:** A Stripe Test API Secret Key was previously committed and has been removed from git history on branch `fix/push-secret-and-release-base`. **You must rotate that key in the Stripe Dashboard** (Developers → API keys → Roll key for the test secret). Use the new key only in local `backend/.env` or in CI/AWS secrets; never commit it. After rotation, push protection on GitHub should pass.

---

## Backend (Spring Boot)

| Variable | Required | Description | Example (dev) |
|----------|----------|-------------|----------------|
| SERVER_PORT | No | HTTP port | 8081 |
| SPRING_PROFILES_ACTIVE | No | Profiles | local,legacy-v1 |
| DB_URL | Yes (prod) | JDBC URL | jdbc:postgresql://host:5432/ayrnow |
| DB_USER | Yes | DB user | ayrnow_app |
| DB_PASSWORD | Yes | DB password | — |
| JWT_SECRET | Yes | Min 32 chars for HMAC | — |
| STRIPE_SECRET_KEY | For payments | Stripe secret key | sk_test_... (test) / sk_live_... (prod) |
| STRIPE_WEBHOOK_SECRET | For webhooks | Stripe webhook signing secret | whsec_... |
| CORS_ALLOWED_ORIGINS | Yes (prod/staging) | CORS origins; must not be * in prod | https://app.ayrnow.com (comma-separated if multiple) |
| APP_BASE_URL | Yes (email auth) | Base URL for verify/reset links in emails (HTTPS in prod) | https://app.ayrnow.com |
| AWS_REGION | Yes (SES) | AWS region for SES | us-east-1 |
| SES_FROM_EMAIL | Yes (SES) | Verified sender email (SES sandbox or production) | noreply@ayrnow.com |
| SES_FROM_NAME | No | Display name in From header | AYRNOW |

**Local:** Use backend/.env (ensure .env is in .gitignore) or export before run_local.sh. For local email testing without SES, leave SES_FROM_EMAIL empty; verification/reset emails will not be sent but registration and reset flows still work (user can use a test token or run backend with SES configured).

---

## Flutter (build/runtime)

| Mechanism | Purpose |
|-----------|--------|
| Build-time / compile-time | Prefer not to bake API URL into release; use runtime or env from CI. |
| Runtime | In-app settings or config file (e.g. assets/config.json) for API base URL. Override for dev (e.g. 127.0.0.1:8081) vs prod. |
| SharedPreferences | Dev override already used for apiBaseUrlOverride (see api_base_url.dart). |

For **production builds**, set or inject production API base URL (e.g. https://api.ayrnow.com) so the app does not call localhost.

---

## AWS (deployment)

- Store DB credentials, JWT_SECRET, Stripe keys in AWS Secrets Manager or Parameter Store.
- Reference in task definition or app config (e.g. ECS env, Lambda env, or .env generated at deploy).

---

## Checklist

- [x] backend/.env in backend/.gitignore and root .gitignore (done on fix/push-secret-and-release-base).
- [ ] backend/.env is not tracked; history on release branch has no .env with secrets (history was rewritten).
- [ ] Rotate any Stripe key that was ever committed (see "Secret rotation requirement" above).
- [ ] No Stripe keys or JWT secrets in repo or current history.
- [ ] Production API URL documented and used in release builds.
- [ ] CI/CD uses secrets from GitHub Secrets or AWS, not from repo.
