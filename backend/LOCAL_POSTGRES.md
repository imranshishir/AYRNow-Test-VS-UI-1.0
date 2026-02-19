# Local Postgres for AYRNOW Backend

Use this to run the Spring Boot backend against a local PostgreSQL database.

## Start Postgres on macOS

**Homebrew:**

```bash
# Common versions: postgresql@14, postgresql@15, postgresql@16, or postgresql (latest)
brew services start postgresql@16
# OR
brew services start postgresql
```

**Verify Postgres is running:**

```bash
pg_isready -h localhost -p 5432
# Should print: localhost:5432 - accepting connections
```

## Create database and user (idempotent)

Run these in `psql` (e.g. `psql postgres` or `psql -U $(whoami)`):

```sql
-- Create user if not exists (idempotent: ignore error if exists)
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'ayrnow_app') THEN
    CREATE ROLE ayrnow_app WITH LOGIN PASSWORD 'ayrnow_dev_password';
  END IF;
END
$$;

-- Create database (idempotent: connect to postgres first)
-- If ayrnow_dev exists, this will error; that's OK.
SELECT 'CREATE DATABASE ayrnow_dev OWNER ayrnow_app'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'ayrnow_dev')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE ayrnow_dev TO ayrnow_app;
\c ayrnow_dev
GRANT ALL ON SCHEMA public TO ayrnow_app;
```

Or use the bootstrap script (see below).

## Environment

The backend expects (defaults in `application.yml`):

- `SPRING_DATASOURCE_URL` — default `jdbc:postgresql://localhost:5432/ayrnow_dev`
- `SPRING_DATASOURCE_USERNAME` — default `ayrnow_app`
- `SPRING_DATASOURCE_PASSWORD` — default `ayrnow_dev_password`

## Bootstrap script

From the project root:

```bash
./scripts/local_db_bootstrap.sh
```

This checks `pg_isready` and creates the user and database if missing. No Docker; requires local Postgres.

## Reset dev database (DESTRUCTIVE)

**This drops the database and all data.**

```bash
psql -h localhost -p 5432 -U "$(whoami)" -d postgres -c "DROP DATABASE IF EXISTS ayrnow_dev;"
```

Then recreate:

```bash
./scripts/local_db_bootstrap.sh
```

Or run the “Create database and user” SQL again.

## Start backend

1. Ensure Postgres is running: `pg_isready -h localhost -p 5432`
2. Ensure DB/user exist (run bootstrap or SQL once).
3. From project root:

```bash
cd backend && ./gradlew bootRun
```
