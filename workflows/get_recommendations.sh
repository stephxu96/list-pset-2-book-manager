#!/usr/bin/env bash
# Coordinates parallel recommendation components, progress, and pipeline cleanup.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCREEN="$ROOT_DIR/ui/recommendations_screen.sh"
HISTORY="$ROOT_DIR/recommendations/recommend_from_history.sh"
INTERESTS="$ROOT_DIR/recommendations/recommend_from_interests.sh"
DISCOVERY="$ROOT_DIR/recommendations/recommend_for_discovery.sh"
REFINE="$ROOT_DIR/recommendations/refine_recommendations.sh"
PARSE_REQUEST="$ROOT_DIR/recommendations/parse_request.sh"

query="$("$SCREEN" collect-context)"
IFS='|' read -r energy format minutes <<< "$("$PARSE_REQUEST" --query "$query")"

printf 'I heard: %s energy' "$energy"
[[ "$format" != "any" ]] && printf ' · %s' "$format"
[[ -n "$minutes" ]] && printf ' · %s minutes' "$minutes"
printf '\n'

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/learning-library.XXXXXX")"
cleanup() { rm -rf "$work_dir"; }
trap cleanup EXIT

"$HISTORY" --query "$query" --energy "$energy" --format "$format" --minutes "$minutes" > "$work_dir/history" &
history_pid=$!
"$INTERESTS" --query "$query" --energy "$energy" --format "$format" --minutes "$minutes" > "$work_dir/interests" &
interests_pid=$!
"$DISCOVERY" --query "$query" --energy "$energy" --format "$format" --minutes "$minutes" > "$work_dir/discovery" &
discovery_pid=$!

printf 'Recommendation agents running'
while kill -0 "$history_pid" 2>/dev/null || kill -0 "$interests_pid" 2>/dev/null || kill -0 "$discovery_pid" 2>/dev/null; do
  printf '.'
  sleep 0.3
done
printf ' done.\n'

wait "$history_pid"
wait "$interests_pid"
wait "$discovery_pid"

# Preserve helpful saved-library matches separately. The required refinement
# pipeline receives all candidates and deliberately removes every saved item,
# leaving a clean shortlist of genuinely new content.
saved_matches="$(cat "$work_dir/history" "$work_dir/interests")"
new_matches="$(cat "$work_dir/history" "$work_dir/interests" "$work_dir/discovery" | "$REFINE")"
"$SCREEN" show-lanes "$saved_matches" "$new_matches"
