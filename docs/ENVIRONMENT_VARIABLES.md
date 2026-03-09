# AYRNOW Environment Variables

**Never commit secrets to the repo.** Use local .env (gitignored), CI secrets, or AWS Parameter Store / Secrets Manager.

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
| ayrnow.cors.allowed-origins | No | CORS origins | * or https://app.ayrnow.com |

**Local:** Use backend/.env (ensure .env is in .gitignore) or export before run_local.sh.

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

- [ ] backend/.env in .gitignore.
- [ ] No Stripe keys or JWT secrets in repo history.
- [ ] Production API URL documented and used in release builds.
- [ ] CI/CD uses secrets from GitHub Secrets or AWS, not from repo.
