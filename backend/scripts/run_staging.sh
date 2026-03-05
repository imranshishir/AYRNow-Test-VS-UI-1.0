#!/usr/bin/env bash
# Phase B13: Run backend for staging
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

command -v mvn >/dev/null 2>&1 || { echo "Error: mvn not found. Install Maven 3.8+."; exit 1; }
[[ -f pom.xml ]] || { echo "Error: pom.xml not found. Run from backend/."; exit 1; }

export SPRING_PROFILES_ACTIVE=staging

REQUIRED_VARS=(
  SPRING_DATASOURCE_URL
  SPRING_DATASOURCE_USERNAME
  SPRING_DATASOURCE_PASSWORD
  JWT_SECRET
  STRIPE_SECRET_KEY
  STRIPE_WEBHOOK_SECRET
)
MISSING=()
for var in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!var}" ]]; then
    MISSING+=("$var")
  fi
done
if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "Error: Required env vars not set: ${MISSING[*]}"
  exit 1
fi

# Stripe URLs (optional but recommended)
: "${STRIPE_SUCCESS_URL:=https://staging.example.com/payment/success}"
: "${STRIPE_CANCEL_URL:=https://staging.example.com/payment/cancel}"

mvn -q -DskipTests spring-boot:run
