#!/usr/bin/env bash
# Coordinates library workflows; it does not read the CSV directly.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIBRARY_UI="$ROOT_DIR/ui/library_screen.sh"
DB="$ROOT_DIR/data/book_database.sh"
METADATA="$ROOT_DIR/books/fetch_book_metadata.sh"
SEARCH="$ROOT_DIR/books/search_books.sh"
PHOTO_IMPORT="$ROOT_DIR/books/import_book_photo.sh"

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

ask_with_default() {
  local label="$1"
  local default="$2"
  if command -v gum >/dev/null 2>&1; then
    gum input --prompt "$label " --value "$default"
  else
    local answer
    printf '%s [%s] ' "$label" "$default" >&2
    read -r answer
    printf '%s\n' "${answer:-$default}"
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

provider_for_type() {
  case "$1" in
    text) choose 'Where is it from?' Amazon Physical Other ;;
    audio) choose 'Where is it from?' Amazon Other ;;
    video) choose 'Where is it from?' YouTube Netflix Other ;;
    guidebook) choose 'Where is it from?' Physical GunksApp Other ;;
  esac
}

status_for_type() {
  case "$1" in
    text|guidebook) choose 'Current status' want_to_read reading finished ;;
    audio) choose 'Current status' want_to_listen listening listened ;;
    video) choose 'Current status' want_to_watch watching watched ;;
  esac
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
    results="$("$SEARCH" "$term")"
    "$LIBRARY_UI" records "$results"
    ;;
  add)
    title="$(ask 'Title:' 'Required')"
    creator="$(ask 'Creator:' 'Author, channel, or creator')"
    content_type="$(choose 'Content type' text audio video guidebook)"
    provider="$(provider_for_type "$content_type")"
    topic="$(choose 'Topic' ai_ml entrepreneurship operations_processes mental_health career climbing physiology_health economics fiction other)"
    status="$(status_for_type "$content_type")"
    reason="$(choose 'Why save it?' class recommendation news curiosity career health_exercise)"
    energy="$(choose 'Energy level' low medium high)"
    record="$("$METADATA" "$title" "$creator" "$content_type" "$provider" "$topic" "$status" "$reason" "$energy")"
    "$DB" add "$record"
    printf 'Added: %s\n' "$title"
    ;;
  import-photo)
    photo_path="$(ask 'Drag a clear book-cover photo here:' '/path/to/photo.jpg')"
    candidate="$("$PHOTO_IMPORT" "$photo_path")"
    IFS='|' read -r guessed_title guessed_creator guessed_topic <<< "$candidate"
    printf 'Codex found a possible title, creator, and topic. Please confirm or correct the details.\n'
    title="$(ask_with_default 'Title:' "$guessed_title")"
    creator="$(ask_with_default 'Creator:' "$guessed_creator")"
    content_type="text"
    provider="Physical"
    all_topics=(ai_ml entrepreneurship operations_processes mental_health career climbing physiology_health economics fiction other)
    photo_topics=("$guessed_topic")
    for topic_option in "${all_topics[@]}"; do
      [[ "$topic_option" == "$guessed_topic" ]] || photo_topics+=("$topic_option")
    done
    topic="$(choose "Topic (Codex suggested: $guessed_topic)" "${photo_topics[@]}")"
    status="$(choose 'Current status' want_to_read reading finished)"
    reason="$(choose 'Why save it?' class recommendation news curiosity career health_exercise)"
    energy="$(choose 'Energy level' low medium high)"
    record="$("$METADATA" "$title" "$creator" "$content_type" "$provider" "$topic" "$status" "$reason" "$energy")"
    "$DB" add "$record"
    printf 'Imported from photo: %s\n' "$title"
    ;;
  *)
    printf 'Usage: %s {browse|videos|search|add|import-photo}\n' "$0" >&2
    exit 1
    ;;
esac
