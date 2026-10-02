#!/usr/bin/env bash
# Optional OCR component. Prints title|creator candidates for a book-cover image.

set -euo pipefail

[[ $# -eq 1 ]] || { printf 'Usage: %s /path/to/book-photo.jpg\n' "$0" >&2; exit 1; }

photo_path="$(printf '%s' "$1" | sed -e 's/^file:\/\///' -e 's/^"//' -e 's/"$//' -e 's/\\ / /g')"
[[ -f "$photo_path" ]] || { printf 'Photo not found: %s\n' "$photo_path" >&2; exit 1; }

if ! command -v tesseract >/dev/null 2>&1; then
  printf 'OCR requires Tesseract. Run ./scripts/setup.sh --install-ocr first.\n' >&2
  exit 1
fi

ocr_text="$(tesseract "$photo_path" stdout 2>/dev/null || true)"
[[ -n "$ocr_text" ]] || { printf 'No readable text found in that photo. Try a clearer, front-facing cover image.\n' >&2; exit 1; }

# A cover's largest/first readable text is usually the title. Confirmation in
# the workflow is mandatory because OCR cannot reliably separate title/author.
title="$(printf '%s\n' "$ocr_text" | awk 'length($0) > 3 { print; exit }' | tr '|,' '  ')"
creator="$(printf '%s\n' "$ocr_text" | awk 'length($0) > 3 { count++; if (count == 2) { print; exit } }' | tr '|,' '  ')"
printf '%s|%s\n' "$title" "$creator"
