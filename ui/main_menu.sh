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
  "Quit"
)

show_book_banner() {
  [[ -t 2 ]] || return 0
  printf '\n' >&2
  printf '        .----------------.\n' >&2
  printf '       /   LEARNING       /|\n' >&2
  printf '      /    LIBRARY       / |\n' >&2
  printf '     /__________________/  |\n' >&2
  printf '     |  read · listen    |  |\n' >&2
  printf '     |  watch · explore  |  /\n' >&2
  printf '     |___________________|/\n' >&2
  printf '        ✦ your next chapter awaits ✦\n\n' >&2
}

if [[ -t 2 ]]; then
  printf '\033[2J\033[H' >&2
fi
show_book_banner

if command -v gum >/dev/null 2>&1; then
  gum choose --header "Learning Library" "${options[@]}"
else
  printf '%s\n' "Gum is not installed; using a basic menu." >&2
  select choice in "${options[@]}"; do
    printf '%s\n' "${choice:-Quit}"
    break
  done
fi
