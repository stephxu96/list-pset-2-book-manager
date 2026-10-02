#!/usr/bin/env bash
# Turns one chat-style request into optional recommendation constraints.

set -euo pipefail

query=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --query) query="$2"; shift 2 ;;
    *) printf 'Usage: %s --query TEXT\n' "$0" >&2; exit 1 ;;
  esac
done

query_lc="$(printf '%s' "$query" | tr '[:upper:]' '[:lower:]')"
energy="medium"
format="any"
minutes=""

if [[ "$query_lc" =~ low[[:space:]-]?energy|tired|easy|light[[:space:]] ]]; then
  energy="low"
elif [[ "$query_lc" =~ high[[:space:]-]?energy|intense|deep[[:space:]]dive|challenging ]]; then
  energy="high"
fi

if [[ "$query_lc" == *"video"* || "$query_lc" == *"youtube"* || "$query_lc" == *"netflix"* || "$query_lc" == *"watch"* ]]; then
  format="video"
elif [[ "$query_lc" == *"audiobook"* || "$query_lc" == *"audio"* || "$query_lc" == *"audible"* || "$query_lc" == *"listen"* ]]; then
  format="audio"
elif [[ "$query_lc" == *"guidebook"* || "$query_lc" == *"climbing guide"* || "$query_lc" == *"beta"* ]]; then
  format="guidebook"
elif [[ "$query_lc" == *"book"* || "$query_lc" == *"read"* || "$query_lc" == *"text"* ]]; then
  format="text"
fi

if [[ "$query_lc" =~ ([0-9]+)[[:space:]]*(minutes?|mins?) ]]; then
  minutes="${BASH_REMATCH[1]}"
fi

printf '%s|%s|%s\n' "$energy" "$format" "$minutes"
