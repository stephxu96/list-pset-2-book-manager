#!/usr/bin/env bash
# Recommends a new item from the curated discovery catalog.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB="$ROOT_DIR/data/book_database.sh"
# shellcheck source=match_helpers.sh
source "$ROOT_DIR/recommendations/match_helpers.sh"

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
query_has_topic_signal "$query_lc" && requires_topic_match=1 || requires_topic_match=0
while IFS= read -r record; do
  IFS=',' read -r id title creator content_type provider provider_format topic location discipline duration item_energy status reason link <<< "$record"
  score=0
  # Honor a requested medium exactly when the user has chosen one.
  [[ "$format" != "any" && "$format" != "$content_type" ]] && continue
  topic_lc="$(printf '%s' "$topic" | tr '[:upper:]' '[:lower:]')"
  if topic_matches_query "$query_lc" "$topic_lc"; then
    semantic_match=1
    score=$((score + 2))
  else
    semantic_match=0
  fi
  [[ "$requires_topic_match" -eq 1 && "$semantic_match" -eq 0 ]] && continue
  [[ "$format" == "any" || "$format" == "$content_type" ]] && score=$((score + 1))
  [[ "$energy" == "$item_energy" ]] && score=$((score + 1))
  if [[ "$score" -ge 2 ]]; then
    printf 'discovery|New option from your curated discovery catalog.|%s\n' "$record"
  fi
done < <("$DB" discovery-list)
