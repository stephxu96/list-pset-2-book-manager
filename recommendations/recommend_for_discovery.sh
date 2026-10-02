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
primary_topic="$(primary_topic_for_query "$query_lc" || true)"
adjacent_topics=()
if [[ -n "$primary_topic" ]]; then
  while IFS= read -r adjacent_topic; do
    adjacent_topics+=("$adjacent_topic")
  done < <(adjacent_topics_for "$primary_topic")
fi

while IFS= read -r record; do
  IFS=',' read -r id title creator content_type provider provider_format topic location discipline duration item_energy status reason link <<< "$record"
  score=0
  stretch_topic=""
  [[ "$format" != "any" && "$format" != "$content_type" ]] && continue
  topic_lc="$(printf '%s' "$topic" | tr '[:upper:]' '[:lower:]')"

  if [[ -n "$primary_topic" ]]; then
    for adjacent_topic in "${adjacent_topics[@]}"; do
      if [[ "$topic_lc" == "$adjacent_topic" ]]; then
        stretch_topic="$adjacent_topic"
        break
      fi
    done
    # A named topic means discovery must deliberately explore an adjacent one.
    [[ -n "$stretch_topic" ]] || continue
    score=$((score + 2))
  fi

  [[ "$format" == "any" || "$format" == "$content_type" ]] && score=$((score + 1))
  [[ "$energy" == "$item_energy" ]] && score=$((score + 1))
  if [[ "$score" -ge 2 ]]; then
    if [[ -n "$primary_topic" ]]; then
      printf 'discovery|Stretch pick: connects %s to %s, an adjacent Discovery Agent topic.|%s\n' "$primary_topic" "$stretch_topic" "$record"
    else
      printf 'discovery|New option from your curated discovery catalog.|%s\n' "$record"
    fi
  fi
done < <("$DB" discovery-list)
