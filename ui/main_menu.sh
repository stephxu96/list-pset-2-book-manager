#!/usr/bin/env bash
# UI only: returns one selected action on stdout.

set -euo pipefail

options=(
  "Browse Learning Library"
  "Browse Video Library"
  "Add Book, Audio, Video, or Guidebook"
  "Import Book from Photo (Bonus)"
  "Search Library"
  "Ask Learning Concierge"
  "Get Recommendations"
  "Quit"
)

if command -v gum >/dev/null 2>&1; then
  gum choose --header "Learning Library" "${options[@]}"
else
  printf '%s\n' "Gum is not installed; using a basic menu." >&2
  select choice in "${options[@]}"; do
    printf '%s\n' "${choice:-Quit}"
    break
  done
fi
