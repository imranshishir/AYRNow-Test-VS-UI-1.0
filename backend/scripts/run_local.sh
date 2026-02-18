#!/usr/bin/env bash
# Phase B13: Run backend locally (DevAuth enabled)
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

command -v mvn >/dev/null 2>&1 || { echo "Error: mvn not found. Install Maven 3.8+."; exit 1; }
[[ -f pom.xml ]] || { echo "Error: pom.xml not found. Run from backend/."; exit 1; }

export SPRING_PROFILES_ACTIVE=local

# Local can use defaults; optionally override
: "${SPRING_DATASOURCE_URL:=jdbc:postgresql://localhost:5432/ayrnow_dev}"
: "${SPRING_DATASOURCE_USERNAME:=imranshishir}"
: "${SPRING_DATASOURCE_PASSWORD:=}"

mvn -q -DskipTests spring-boot:run
