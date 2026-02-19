#!/usr/bin/env bash
# Idempotent local Postgres bootstrap for AYRNOW backend.
# Creates user ayrnow_app and database ayrnow_dev if missing.
# Requires: Postgres running locally (e.g. brew services start postgresql@16).
# Usage: from project root, ./scripts/local_db_bootstrap.sh

set -e

HOST="${PGHOST:-localhost}"
PORT="${PGPORT:-5432}"
USER="${PGUSER:-$(whoami)}"
ADMIN_DB="${PGADMIN_DB:-postgres}"
APP_USER="ayrnow_app"
APP_PASS="ayrnow_dev_password"
APP_DB="ayrnow_dev"

if ! command -v pg_isready &>/dev/null; then
  echo "pg_isready not found. Install PostgreSQL (e.g. brew install postgresql@16)."
  exit 1
fi

if ! pg_isready -h "$HOST" -p "$PORT" >/dev/null 2>&1; then
  echo "Postgres is not ready at $HOST:$PORT. Start it first (e.g. brew services start postgresql@16)."
  exit 1
fi

# Create app user if not exists
psql -h "$HOST" -p "$PORT" -U "$USER" -d "$ADMIN_DB" -v ON_ERROR_STOP=1 -c "
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${APP_USER}') THEN
    CREATE ROLE ${APP_USER} WITH LOGIN PASSWORD '${APP_PASS}';
  END IF;
END \$\$;
"

# Create database (ignore error if already exists)
psql -h "$HOST" -p "$PORT" -U "$USER" -d "$ADMIN_DB" -v ON_ERROR_STOP=0 -c "CREATE DATABASE ${APP_DB} OWNER ${APP_USER};" || true

# Grant schema
psql -h "$HOST" -p "$PORT" -U "$USER" -d "$APP_DB" -v ON_ERROR_STOP=1 -c "GRANT ALL ON SCHEMA public TO ${APP_USER};"

echo "DB ready: ${APP_DB} (user ${APP_USER})"
