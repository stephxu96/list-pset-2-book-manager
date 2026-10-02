#!/usr/bin/env bash
# Validate local prerequisites. Pass --install to install Gum with a supported package manager.

set -euo pipefail

install_gum=false
case "${1:-}" in
  "") ;;
  --install) install_gum=true ;;
  -h|--help)
    printf 'Usage: %s [--install]\n' "$0"
    printf '  --install  Install Gum using Homebrew or apt-get.\n'
    exit 0
    ;;
  *)
    printf 'Unknown option: %s\n' "$1" >&2
    exit 1
    ;;
esac

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

command -v bash >/dev/null 2>&1 || { printf 'Bash is required.\n' >&2; exit 1; }

if command -v gum >/dev/null 2>&1; then
  printf 'Gum found: %s\n' "$(gum --version)"
elif [[ "$install_gum" == true && "$(command -v brew || true)" != "" ]]; then
  printf 'Installing Gum with Homebrew...\n'
  brew install gum
elif [[ "$install_gum" == true && "$(command -v apt-get || true)" != "" ]]; then
  printf 'Installing Gum with apt-get...\n'
  sudo apt-get update
  sudo apt-get install -y gum
else
  printf 'Gum is not installed.\n' >&2
  printf 'Install it with one of these commands:\n' >&2
  printf '  macOS/Homebrew: brew install gum\n' >&2
  printf '  Debian/Ubuntu:  sudo apt-get install gum\n' >&2
  printf 'Or run: ./scripts/setup.sh --install\n' >&2
  exit 1
fi

if ! command -v gum >/dev/null 2>&1; then
  printf 'Gum installation did not complete.\n' >&2
  exit 1
fi

for script in "$ROOT_DIR"/app.sh "$ROOT_DIR"/ui/*.sh "$ROOT_DIR"/workflows/*.sh "$ROOT_DIR"/books/*.sh "$ROOT_DIR"/recommendations/*.sh "$ROOT_DIR"/data/book_database.sh; do
  bash -n "$script"
done

awk -F',' 'NR > 1 && NF != 14 { printf "Invalid CSV row %d: expected 14 fields, found %d\\n", NR, NF; exit 1 }' \
  "$ROOT_DIR/data/books.csv" "$ROOT_DIR/data/discovery_catalog.csv"

printf 'Setup validation complete. Start the application with: ./app.sh\n'
