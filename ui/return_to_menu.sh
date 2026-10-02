#!/usr/bin/env bash
# UI only: gives completed flows a visible end state before returning home.

set -euo pipefail

# Do not block scripted checks or piped workflows.
[[ -t 0 && -t 1 ]] || exit 0

printf '\n────────────────────────────────────────────────────────\n'
printf 'Press Enter to return to the main menu...'
IFS= read -r _
