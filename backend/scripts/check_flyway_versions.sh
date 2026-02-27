#!/usr/bin/env bash
# Check for duplicate Flyway migration versions across db/migration and db-local.
# Exit 1 if duplicates found.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOURCES="${SCRIPT_DIR}/../src/main/resources"

echo "Scanning Flyway migrations..."
ALL_VERSIONS=""

for dir in "db/migration" "db-local"; do
  FULL="${RESOURCES}/${dir}"
  [[ ! -d "$FULL" ]] && continue
  for f in "$FULL"/V*.sql "$FULL"/R*.sql; do
    [[ -f "$f" ]] || continue
    base=$(basename "$f")
    ver="${base%%__*}"
    ALL_VERSIONS="${ALL_VERSIONS}${ver}|${f}"$'\n'
  done
done

DUPS=$(echo "$ALL_VERSIONS" | cut -d'|' -f1 | sort | uniq -d)
if [[ -n "$DUPS" ]]; then
  echo "ERROR: Duplicate migration version(s): $DUPS"
  for v in $DUPS; do
    echo "$ALL_VERSIONS" | grep "^${v}|" | sed 's/^/  /'
  done
  exit 1
fi

echo "OK: No duplicate versions found."
echo "$ALL_VERSIONS" | grep -v '^$' | cut -d'|' -f1 | sort -V | while read v; do
  path=$(echo "$ALL_VERSIONS" | grep "^${v}|" | cut -d'|' -f2)
  echo "  $v -> $path"
done
