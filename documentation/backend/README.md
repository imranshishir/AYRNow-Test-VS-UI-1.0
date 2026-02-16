# AYRNOW Backend Documentation

Central index for backend developer docs, runbooks, API testing, and deployment.

---

## What is AYRNOW Backend?

AYRNOW backend is a **Spring Boot 3.x monolithic REST API** for property and tenant management. It provides multi-tenant operations (accounts, properties, units, leases), maintenance tickets, contractor assignments, community posts, security visitors, ledger (charges/payments), Stripe checkout, and tenant transfer profiles. Auth uses JWT (access + refresh tokens) with optional DevAuth headers for local development.

The API is versioned under `/api/v1`, uses PostgreSQL with Flyway migrations, and is deployed as a plain JAR (no Docker). All queries are account-scoped; cross-account access is never permitted.

---

## Quick Start

| Doc | Purpose |
|-----|---------|
| [HANDOFF.md](HANDOFF.md) | Architecture, domain model, conventions, how to add features |
| [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md) | ASCII diagrams: system, domain, auth, Stripe webhook, ledger |
| [RUN_LOCAL.md](RUN_LOCAL.md) | Run locally: prereqs, DB, Flyway, auth modes, troubleshooting |
| [API_TESTING.md](API_TESTING.md) | Full endpoint reference + curl examples + happy path |
| [DEPLOY.md](DEPLOY.md) | Staging/prod deployment, AWS EC2+RDS, systemd, HTTPS |
| [postman/AYRNOW.postman_collection.json](postman/AYRNOW.postman_collection.json) | Postman collection (import, set BASE_URL and ACCESS_TOKEN) |

**Swagger UI:** When running locally: http://localhost:8080/swagger-ui.html  
**OpenAPI JSON:** http://localhost:8080/api/docs

---

## Docs Index

- **[HANDOFF.md](HANDOFF.md)** — Developer handoff: layers, domain model, conventions, add-feature steps, roadmap
- **[ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)** — ASCII diagrams: system, domain, auth flow, Stripe webhook, ledger flow
- **[RUN_LOCAL.md](RUN_LOCAL.md)** — Prereqs, create DB, run app, Flyway, auth (JWT / DevAuth), troubleshooting
- **[API_TESTING.md](API_TESTING.md)** — Every endpoint with curl, auth, response shape, errors, happy path walkthrough
- **[DEPLOY.md](DEPLOY.md)** — Env vars, Postgres, build/run, systemd, HTTPS (Caddy/Nginx), AWS EC2+RDS, Stripe webhooks, smoke tests
