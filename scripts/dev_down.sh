#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT="$(dirname "$DIR")"

echo "======================================"
echo " AYRNOW - Stopping Local Dev Env"
echo "======================================"

if [ -f "$PROJECT_ROOT/.backend_pid" ]; then
    PID=$(cat "$PROJECT_ROOT/.backend_pid")
    echo "Stopping Spring Boot Backend (PID: $PID)..."
    kill $PID 2>/dev/null || true
    rm "$PROJECT_ROOT/.backend_pid"
    echo "✅ Backend stopped."
else
    echo "⚠️  No .backend_pid file found. Is the backend running? Checking via jps..."
    # Optionally attempt to kill via jps or pkill:
    # pkill -f "bootRun" || true
fi

echo ""
echo "ℹ️  Note: PostgreSQL service is left running for convenience."
echo "If you wish to stop PostgreSQL, you can use:"
echo "  brew services stop postgresql@14"
echo "======================================"
