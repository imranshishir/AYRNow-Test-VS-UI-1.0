#!/usr/bin/env bash
# Run backend locally with default DB and port. From backend/: ./scripts/run_local.sh
# Override any variable before running if needed (e.g. DB_URL, SERVER_PORT).

set -e
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

# Include legacy-v1 so v1/payments/intent and v1/payments/mine are available for the app.
export SPRING_PROFILES_ACTIVE="${SPRING_PROFILES_ACTIVE:-local,legacy-v1}"
export SERVER_PORT="${SERVER_PORT:-8081}"
export DB_URL="${DB_URL:-jdbc:postgresql://localhost:5432/ayrnow_dev}"
export DB_USER="${DB_USER:-ayrnow_app}"
export DB_PASSWORD="${DB_PASSWORD:-ayrnow_dev_password}"
export JWT_SECRET="${JWT_SECRET:-change_me_dev_secret_min_32_characters_long_for_hmac256}"

./gradlew bootRun
