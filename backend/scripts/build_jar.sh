#!/usr/bin/env bash
# Phase B13: Build deployable JAR
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

command -v mvn >/dev/null 2>&1 || { echo "Error: mvn not found. Install Maven 3.8+."; exit 1; }
[[ -f pom.xml ]] || { echo "Error: pom.xml not found. Run from backend/."; exit 1; }

mvn clean package -DskipTests -q

JAR=$(ls -1 target/*.jar 2>/dev/null | grep -v "original" | head -1)
if [[ -z "$JAR" ]]; then
  echo "Error: No JAR found in target/"
  exit 1
fi

echo "Built: $JAR"
echo ""
echo "Run with production profile:"
echo "  export SPRING_PROFILES_ACTIVE=prod"
echo "  export SPRING_DATASOURCE_URL=..."
echo "  export SPRING_DATASOURCE_USERNAME=..."
echo "  export SPRING_DATASOURCE_PASSWORD=..."
echo "  export JWT_SECRET=..."
echo "  export STRIPE_SECRET_KEY=..."
echo "  export STRIPE_WEBHOOK_SECRET=..."
echo ""
echo "  java -jar $JAR"
