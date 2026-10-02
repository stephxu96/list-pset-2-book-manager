#!/usr/bin/env bash
# A small terminal-native welcome animation. It is skipped for non-interactive runs.

set -euo pipefail

[[ -t 1 && "${NO_LAUNCH_ANIMATION:-false}" != "true" ]] || exit 0

frames=(
'        .--------.
       /  ____     /|
      /__/__/____/ |
      |  LEARN  |  |
      | LIBRARY |  /
      |_________|/'
'        .--------.
       /  ____     /|
      /__/__/____/ |
      |  LEARN  |  |
      | LIBRARY | /~
      |_________|/'
'        .--------.
       /  ____     /|
      /__/__/____/ |
      |  LEARN  |  |
      | LIBRARY |  \
      |_________|\\'
)

printf '\033[?25l'
for frame in "${frames[@]}"; do
  printf '\033[2J\033[H\n%s\n\n       opening your next chapter...\n' "$frame"
  sleep 0.16
done
printf '\033[2J\033[H\033[?25h'
