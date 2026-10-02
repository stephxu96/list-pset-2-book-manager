#!/usr/bin/env bash
# UI only: collects Concierge context and displays recommendation candidates.

set -euo pipefail

prompt() {
  local label="$1"
  local placeholder="$2"
  if command -v gum >/dev/null 2>&1; then
    gum input --prompt "$label " --placeholder "$placeholder"
  else
    printf '%s ' "$label" >&2
    read -r value
    printf '%s\n' "$value"
  fi
}

collect_context() {
  prompt 'What should I learn or watch next?' 'e.g. I have 20 minutes and want a low-energy climbing video'
}

show_records() {
  local heading="$1"
  local records="$2"
  printf '\n%s\n' "$heading"
  if [[ -z "$records" ]]; then
    printf 'No items in this section.\n'
    return
  fi

  while IFS='|' read -r origin reason record; do
    IFS=',' read -r id title creator content_type provider provider_format topic location discipline duration energy status saved_reason link <<< "$record"
    printf '\n• %s [%s via %s]\n' "$title" "$content_type" "$provider_format"
    printf '  Creator: %s | Topic: %s | Energy: %s\n' "$creator" "$topic" "$energy"
    [[ -n "$duration" ]] && printf '  Length: %s\n' "$duration"
    [[ -n "$location" ]] && printf '  Location: %s%s\n' "$location" "${discipline:+ ($discipline)}"
    printf '  Why: %s (%s)\n' "$reason" "$origin"
  done <<< "$records"
}

show_recommendations() {
  local saved_records="${1:-}"
  local new_records="${2:-}"
  printf '\nLearning Concierge recommendations\n'
  show_records 'Start from your library' "$saved_records"
  show_records 'Explore something new' "$new_records"
  printf '\n'
}

case "${1:-}" in
  collect-context) collect_context ;;
  show|show-lanes) show_recommendations "${2:-}" "${3:-}" ;;
  *)
    printf 'Usage: %s {collect-context|show}\n' "$0" >&2
    exit 1
    ;;
esac
