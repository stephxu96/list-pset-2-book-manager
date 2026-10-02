#!/usr/bin/env bash
# Learning Library - application entry point.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RETURN_TO_MENU="$ROOT_DIR/ui/return_to_menu.sh"

clear_screen() {
  [[ -t 1 ]] || return 0
  printf '\033[2J\033[H'
}

run_flow() {
  clear_screen
  "$@"
  "$RETURN_TO_MENU"
}

"$ROOT_DIR/ui/launch_animation.sh"

while true; do
  choice="$("$ROOT_DIR/ui/main_menu.sh")"
  case "$choice" in
    "Browse Learning Library")
      run_flow "$ROOT_DIR/workflows/manage_library.sh" browse
      ;;
    "Browse Video Library")
      run_flow "$ROOT_DIR/workflows/manage_library.sh" videos
      ;;
    "Add Book, Audio, Video, or Guidebook")
      run_flow "$ROOT_DIR/workflows/manage_library.sh" add
      ;;
    "Import Book from Photo (Bonus)")
      run_flow "$ROOT_DIR/workflows/manage_library.sh" import-photo
      ;;
    "Search Library")
      run_flow "$ROOT_DIR/workflows/manage_library.sh" search
      ;;
    "Ask Learning Concierge")
      run_flow "$ROOT_DIR/workflows/get_recommendations.sh"
      ;;
    "Quit"|"")
      printf 'Goodbye.\n'
      break
      ;;
  esac
done
