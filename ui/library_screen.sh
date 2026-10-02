#!/usr/bin/env bash
# UI only: turns library records into readable terminal output.

set -euo pipefail

mode="${1:-show}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB="$ROOT_DIR/data/book_database.sh"

show_records() {
  local records="$1"
  if [[ -z "$records" ]]; then
    printf 'No matching items found.\n'
    return
  fi
  printf '\n%-28s %-10s %-12s %-22s %-16s\n' 'TITLE' 'TYPE' 'PROVIDER' 'TOPIC' 'STATUS'
  printf '%-28s %-10s %-12s %-22s %-16s\n' '----------------------------' '----------' '------------' '----------------------' '----------------'
  while IFS=',' read -r id title creator content_type provider provider_format topic location discipline duration energy status reason link; do
    [[ -z "$id" ]] && continue
    printf '%-28.28s %-10s %-12s %-22.22s %-16s\n' "$title" "$content_type" "$provider" "$topic" "$status"
  done <<< "$records"
  printf '\n'
}

case "$mode" in
  show)
    printf '\nYour Learning Library\n'
    show_records "$("$DB" list)"
    ;;
  videos)
    printf '\nYour Video Library\n'
    show_records "$("$DB" list | awk -F',' '$4 == "video"')"
    ;;
  search)
    show_records "$("$DB" search "${2:-}")"
    ;;
  *)
    printf 'Unknown library display mode: %s\n' "$mode" >&2
    exit 1
    ;;
esac
