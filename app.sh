#!/usr/bin/env bash
# Learning Library - application entry point.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while true; do
  choice="$("$ROOT_DIR/ui/main_menu.sh")"
  case "$choice" in
    "Browse Learning Library")
      "$ROOT_DIR/workflows/manage_library.sh" browse
      ;;
    "Browse Video Library")
      "$ROOT_DIR/workflows/manage_library.sh" videos
      ;;
    "Add Book, Audio, Video, or Guidebook")
      "$ROOT_DIR/workflows/manage_library.sh" add
      ;;
    "Search Library")
      "$ROOT_DIR/workflows/manage_library.sh" search
      ;;
    "Ask Learning Concierge"|"Get Recommendations")
      "$ROOT_DIR/workflows/get_recommendations.sh"
      ;;
    "Quit"|"")
      printf 'Goodbye.\n'
      break
      ;;
  esac
done
