#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT="$(dirname "$DIR")"

echo "======================================"
echo " AYRNOW - Starting Local Dev Env"
echo "======================================"

# 1. Bootstrap PostgreSQL (creates DB and users if needed)
"$DIR/local_pg_bootstrap.sh"

export SPRING_PROFILES_ACTIVE=local

echo ""
echo "Starting Backend (Spring Boot)..."
cd "$PROJECT_ROOT/backend"
# Run backend in the background. We can use gradle or run the built jar. Gradle bootRun is easier for dev.
./gradlew bootRun &
BACKEND_PID=$!
echo $BACKEND_PID > "$PROJECT_ROOT/.backend_pid"

echo ""
echo "✅ Backend is starting! PID stored in .backend_pid: $BACKEND_PID"
echo "Tail logs using: tail -f backend/build/bootRun.log (if customized) or just let it output here."
echo "Press Ctrl+C to exit this script (note: backend will keep running, use dev_down.sh to stop)."

wait $BACKEND_PID
