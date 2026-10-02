#!/usr/bin/env bash
# Recommends saved items adjacent to completed material and the current topic.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB="$ROOT_DIR/data/book_database.sh"

query=""; energy=""; format=""; minutes=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --query) query="$2"; shift 2 ;;
    --energy) energy="$2"; shift 2 ;;
    --format) format="$2"; shift 2 ;;
    --minutes) minutes="$2"; shift 2 ;;
    *) exit 1 ;;
  esac
done

query_lc="$(printf '%s' "$query" | tr '[:upper:]' '[:lower:]')"
while IFS= read -r record; do
  IFS=',' read -r id title creator content_type provider provider_format topic location discipline duration item_energy status reason link <<< "$record"
  case "$status" in finished|listened|watched) ;; *) continue ;; esac
  topic_lc="$(printf '%s' "$topic" | tr '[:upper:]' '[:lower:]')"
  if [[ "$query_lc" == *"$topic_lc"* ]]; then
    printf 'saved|Matches a topic in your completed history: %s|%s\n' "$topic" "$record"
  fi
done < <("$DB" list)
