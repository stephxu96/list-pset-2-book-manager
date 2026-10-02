#!/usr/bin/env bash
# Deterministic Codex CLI stand-in for unit tests; never contacts a live model.

set -euo pipefail
output_file=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-last-message) output_file="$2"; shift 2 ;;
    *) shift ;;
  esac
done
[[ -n "$output_file" ]]
printf '{"recommendations":[{"item_id":"%s","reason":"Mock model match"}]}\n' \
  "${MOCK_RECOMMENDATION_ID:-a001}" > "$output_file"
