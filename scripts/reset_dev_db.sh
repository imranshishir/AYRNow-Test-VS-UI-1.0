#!/usr/bin/env bash
# DESTRUCTIVE: Local dev only. Drops and recreates ayrnow_dev, then runs bootstrap.
# Use when you need a clean schema from current Flyway migrations.
# From repo root: ./scripts/reset_dev_db.sh

set -e

HOST="${PGHOST:-localhost}"
PORT="${PGPORT:-5432}"
USER="${PGUSER:-$(whoami)}"
ADMIN_DB="${PGADMIN_DB:-postgres}"
APP_USER="ayrnow_app"
APP_DB="ayrnow_dev"

if ! command -v psql &>/dev/null; then
  echo "psql not found. Install PostgreSQL (e.g. brew install postgresql@15)."
  exit 1
fi

if ! pg_isready -h "$HOST" -p "$PORT" >/dev/null 2>&1; then
  echo "Postgres is not ready at $HOST:$PORT. Start it first (e.g. brew services start postgresql@15)."
  exit 1
fi

echo "Terminating connections to ${APP_DB}..."
psql -h "$HOST" -p "$PORT" -U "$USER" -d "$ADMIN_DB" -v ON_ERROR_STOP=0 -c "
  SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${APP_DB}' AND pid <> pg_backend_pid();
"
echo "Dropping database ${APP_DB} (if exists)..."
psql -h "$HOST" -p "$PORT" -U "$USER" -d "$ADMIN_DB" -v ON_ERROR_STOP=1 -c "DROP DATABASE IF EXISTS ${APP_DB};"

echo "Running bootstrap..."
./scripts/local_db_bootstrap.sh

echo ""
echo "Next steps:"
echo "  cd backend && ./gradlew bootRun"
echo "  Then: curl http://localhost:8080/actuator/health"
