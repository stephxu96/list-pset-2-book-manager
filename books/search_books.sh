#!/usr/bin/env bash
# Searches all saved content; accepts an argument or stdin for pipeline use.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB="$ROOT_DIR/data/book_database.sh"

if [[ $# -gt 0 ]]; then
  term="$1"
else
  IFS= read -r term || term=""
fi

"$DB" search "$term"
