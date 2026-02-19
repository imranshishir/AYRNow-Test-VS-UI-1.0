# AYRNOW Backend (Phase 1)

Spring Boot 3.x backend for the AYRNOW Flutter app. Minimal Phase 1 scope with JWT auth, PostgreSQL, Flyway, and Stripe stub.

## Prerequisites

- Java 17
- PostgreSQL 14+

## Run the app locally

1. **Start Postgres** (see [LOCAL_POSTGRES.md](LOCAL_POSTGRES.md) for Homebrew and one-time DB setup).
2. Optional: create DB/user with `./scripts/local_db_bootstrap.sh` from project root.
3. Run the backend:

```bash
cd backend
./gradlew bootRun
```

Server runs on port 8080.

## Local database setup (one-time)

See **[LOCAL_POSTGRES.md](LOCAL_POSTGRES.md)** for:

- Starting Postgres on macOS (`brew services start postgresql@16`)
- Idempotent create user/db and `scripts/local_db_bootstrap.sh`
- Reset dev DB (destructive)

Server runs on port 8080.

## Sample curl commands

### Login

```bash
curl -X POST http://localhost:8080/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"landlord@example.com","role":"landlord"}'
```

Response:
```json
{"token":"eyJ...","role":"landlord","userId":"..."}
```

### Get current user (with token)

```bash
TOKEN="<paste token from login>"
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/v1/me
```

### Rent board

```bash
# Use property ID from seed: 33333333-3333-3333-3333-333333333333
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/v1/rent-board?propertyId=33333333-3333-3333-3333-333333333333"
```

### Tickets

```bash
# List tickets
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/v1/tickets?propertyId=33333333-3333-3333-3333-333333333333"

# Create ticket
curl -X POST -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "propertyId":"33333333-3333-3333-3333-333333333333",
    "unitId":"44444444-4444-4444-4444-444444444444",
    "title":"Broken window",
    "description":"Living room window cracked",
    "priority":"High"
  }' \
  http://localhost:8080/v1/tickets
```

### Notifications

```bash
curl -H "Authorization: Bearer $TOKEN" http://localhost:8080/v1/notifications
```

## Environment variables (EC2)

| Variable | Description | Example |
|----------|-------------|---------|
| `SPRING_DATASOURCE_URL` | PostgreSQL JDBC URL | `jdbc:postgresql://host:5432/ayrnow` |
| `SPRING_DATASOURCE_USERNAME` | DB user | `ayrnow_app` |
| `SPRING_DATASOURCE_PASSWORD` | DB password | (secret) |
| `JWT_SECRET` | JWT signing secret (min 32 chars) | (secret) |
| `STRIPE_SECRET_KEY` | Stripe API key (optional) | `sk_live_...` |

## Health check

```bash
curl http://localhost:8080/actuator/health
```

## Run tests

```bash
./gradlew test
```

Tests use H2 in-memory database; no PostgreSQL required.

## GitHub Actions – EC2 Deploy

On push to `main` (backend changes only), the workflow builds, tests, and deploys the JAR to EC2 via SSH.

### Required GitHub Secrets

| Secret        | Description                         |
|---------------|-------------------------------------|
| `EC2_HOST`    | EC2 instance IP or hostname         |
| `EC2_USER`    | SSH user (default: `ubuntu`)        |
| `EC2_SSH_KEY` | Private key contents (PEM) for SSH  |

Add these under **Settings → Secrets and variables → Actions**.

### Manual run

Trigger manually: **Actions → Deploy Backend to EC2 → Run workflow**.

### EC2 setup

See [DEPLOY_EC2.md](DEPLOY_EC2.md) for bootstrap commands (Java 17, `/opt/ayrnow`, systemd service).
