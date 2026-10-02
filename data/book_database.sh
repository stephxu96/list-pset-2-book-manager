#!/usr/bin/env bash
# The only component allowed to directly read/write books.csv.

set -euo pipefail

DATA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOKS_FILE="$DATA_DIR/books.csv"
DISCOVERY_FILE="$DATA_DIR/discovery_catalog.csv"

usage() {
  printf 'Usage: %s {list|discovery-list|search|exists|add|update-status} [argument]\n' "$0" >&2
  exit 1
}

list_file() {
  local file="$1"
  tail -n +2 "$file"
}

case "${1:-}" in
  list)
    list_file "$BOOKS_FILE"
    ;;
  discovery-list)
    list_file "$DISCOVERY_FILE"
    ;;
  search)
    [[ $# -eq 2 ]] || usage
    term="$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')"
    list_file "$BOOKS_FILE" | awk -v needle="$term" 'tolower($0) ~ needle'
    ;;
  exists)
    [[ $# -eq 2 ]] || usage
    title="$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')"
    awk -F',' -v needle="$title" 'NR > 1 && tolower($2) == needle { found=1 } END { exit(found ? 0 : 1) }' "$BOOKS_FILE"
    ;;
  add)
    [[ $# -eq 2 ]] || usage
    record="$(printf '%s' "$2" | tr '\n\r' '  ')"
    id="${record%%,*}"
    [[ -n "$id" ]] || { printf 'An id is required.\n' >&2; exit 1; }
    if awk -F',' -v id="$id" 'NR > 1 && $1 == id { found=1 } END { exit(found ? 0 : 1) }' "$BOOKS_FILE"; then
      printf 'An item with id %s already exists.\n' "$id" >&2
      exit 1
    fi
    # Some editors leave the CSV without a final newline. Separate the next
    # record first so it cannot be glued onto the last existing row.
    if [[ -s "$BOOKS_FILE" ]]; then
      last_byte="$(tail -c 1 "$BOOKS_FILE")"
      [[ -z "$last_byte" ]] || printf '\n' >> "$BOOKS_FILE"
    fi
    printf '%s\n' "$record" >> "$BOOKS_FILE"
    ;;
  update-status)
    [[ $# -eq 3 ]] || usage
    item_id="$2"
    new_status="$(printf '%s' "$3" | tr ',\n\r' '   ')"
    temp_file="$(mktemp "${BOOKS_FILE}.XXXXXX")"
    awk -F',' -v OFS=',' -v id="$item_id" -v status="$new_status" '
      NR == 1 { print; next }
      $1 == id { $12 = status; found=1 }
      { print }
      END { exit(found ? 0 : 1) }
    ' "$BOOKS_FILE" > "$temp_file" || { rm -f "$temp_file"; exit 1; }
    mv "$temp_file" "$BOOKS_FILE"
    ;;
  *) usage ;;
esac
