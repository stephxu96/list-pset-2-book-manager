#!/usr/bin/env bash
# Coordinates parallel recommendation components, progress, and pipeline cleanup.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCREEN="$ROOT_DIR/ui/recommendations_screen.sh"
HISTORY="$ROOT_DIR/recommendations/recommend_from_history.sh"
INTERESTS="$ROOT_DIR/recommendations/recommend_from_interests.sh"
DISCOVERY="$ROOT_DIR/recommendations/recommend_for_discovery.sh"
REFINE="$ROOT_DIR/recommendations/refine_recommendations.sh"

query="$("$SCREEN" collect-context)"
command -v jq >/dev/null 2>&1 || { printf 'jq is required for live recommendations.\n' >&2; exit 1; }

records_to_json() {
  printf '%s\n' "$1" | jq -Rn '[inputs | split(",") | {
    id: .[0], title: .[1], creator: .[2], content_type: .[3],
    provider: .[4], provider_format: .[5], topic: .[6], location: .[7],
    discipline: .[8], duration: .[9], energy: .[10], status: .[11],
    reason_saved: .[12], link: .[13], raw: join(",")
  }]'
}

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/learning-library.XXXXXX")"
cleanup() { rm -rf "$work_dir"; }
trap cleanup EXIT

library_json="$(records_to_json "$("$ROOT_DIR/data/book_database.sh" list)")"
discovery_json="$(records_to_json "$("$ROOT_DIR/data/book_database.sh" discovery-list)")"
jq -n --arg request "$query" --argjson library "$library_json" \
  --argjson discovery_catalog "$discovery_json" \
  '{request: $request, library: $library, discovery_catalog: $discovery_catalog}' > "$work_dir/context.json"

"$HISTORY" < "$work_dir/context.json" > "$work_dir/history" &
history_pid=$!
"$INTERESTS" < "$work_dir/context.json" > "$work_dir/interests" &
interests_pid=$!
"$DISCOVERY" < "$work_dir/context.json" > "$work_dir/discovery" &
discovery_pid=$!

printf 'Live recommendation agents are considering your request'
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
