#!/usr/bin/env bash
# Reset local DB and optionally start backend.
# Usage: ./scripts/reset_local_db.sh [--start]
#   --start  Start backend after reset (default: just reset DB)
#
# IMPORTANT: Stop the backend first (Ctrl+C or kill the process).
#            If dropdb fails with "database is being accessed", stop all connections.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

DB_NAME="${PGDATABASE:-ayrnow_dev}"

echo "Resetting database: $DB_NAME"
if command -v dropdb >/dev/null 2>&1 && command -v createdb >/dev/null 2>&1; then
  if ! dropdb --if-exists "$DB_NAME"; then
    echo "ERROR: Could not drop $DB_NAME. Stop the backend and any DB connections, then retry."
    exit 1
  fi
  if ! createdb "$DB_NAME"; then
    echo "ERROR: Could not create $DB_NAME."
    exit 1
  fi
  echo "OK: Database $DB_NAME dropped and recreated."
else
  echo "WARN: dropdb/createdb not found. Run manually:"
  echo "  dropdb $DB_NAME"
  echo "  createdb $DB_NAME"
  exit 1
fi

if [[ "${1:-}" == "--start" ]]; then
  echo "Starting backend..."
  export SPRING_PROFILES_ACTIVE=local
  : "${SPRING_DATASOURCE_URL:=jdbc:postgresql://localhost:5432/$DB_NAME}"
  mvn -q -DskipTests spring-boot:run
fi
