#!/usr/bin/env bash
# Coordinates library workflows; it does not read the CSV directly.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIBRARY_UI="$ROOT_DIR/ui/library_screen.sh"
DB="$ROOT_DIR/data/book_database.sh"
METADATA="$ROOT_DIR/books/fetch_book_metadata.sh"

ask() {
  local label="$1"
  local placeholder="$2"
  if command -v gum >/dev/null 2>&1; then
    gum input --prompt "$label " --placeholder "$placeholder"
  else
    printf '%s ' "$label" >&2
    read -r answer
    printf '%s\n' "$answer"
  fi
}

choose() {
  local label="$1"
  shift
  if command -v gum >/dev/null 2>&1; then
    gum choose --header "$label" "$@"
  else
    printf '%s\n' "$label" >&2
    select answer in "$@"; do
      printf '%s\n' "${answer:-$1}"
      break
    done
  fi
}

case "${1:-}" in
  browse)
    "$LIBRARY_UI" show
    ;;
  videos)
    "$LIBRARY_UI" videos
    ;;
  search)
    term="$(ask 'Search your library:' 'AI, climbing, Audible, strategy...')"
    "$LIBRARY_UI" search "$term"
    ;;
  add)
    title="$(ask 'Title:' 'Required')"
    creator="$(ask 'Creator:' 'Author, channel, or creator')"
    content_type="$(choose 'Content type' text audio video guidebook)"
    provider="$(choose 'Provider' Amazon YouTube Netflix Physical GunksApp Other)"
    topic="$(choose 'Topic' ai_ml entrepreneurship operations_processes mental_health career climbing physiology_health economics fiction other)"
    status="$(choose 'Current status' want_to_read reading finished want_to_listen listening listened want_to_watch watching watched)"
    reason="$(choose 'Why save it?' class recommendation news curiosity career health_exercise)"
    energy="$(choose 'Energy level' low medium high)"
    record="$("$METADATA" "$title" "$creator" "$content_type" "$provider" "$topic" "$status" "$reason" "$energy")"
    "$DB" add "$record"
    printf 'Added: %s\n' "$title"
    ;;
  *)
    printf 'Usage: %s {browse|videos|search|add}\n' "$0" >&2
    exit 1
    ;;
esac
