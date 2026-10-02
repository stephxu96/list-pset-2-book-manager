#!/usr/bin/env bash
# Optional Codex-vision component. Prints title|creator|topic from a cover image.

set -euo pipefail

[[ $# -eq 1 ]] || { printf 'Usage: %s /path/to/book-photo.jpg\n' "$0" >&2; exit 1; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEMA="$ROOT_DIR/books/book_metadata_schema.json"
photo_path="$(printf '%s' "$1" | sed -e 's/^file:\/\///' -e 's/^"//' -e 's/"$//' -e 's/\\ / /g')"
[[ -f "$photo_path" ]] || { printf 'Photo not found: %s\n' "$photo_path" >&2; exit 1; }
command -v codex >/dev/null 2>&1 || { printf 'Codex CLI is required for photo import. Install and sign in to Codex first.\n' >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { printf 'jq is required to read Codex metadata output.\n' >&2; exit 1; }

codex_image="$photo_path"
temp_dir=""
cleanup() { [[ -n "$temp_dir" ]] && rm -rf "$temp_dir"; }
trap cleanup EXIT

# Codex vision accepts common web formats. Convert an iPhone HEIC locally first.
extension="$(printf '%s' "${photo_path##*.}" | tr '[:upper:]' '[:lower:]')"
if [[ "$extension" == "heic" || "$extension" == "heif" ]]; then
  command -v sips >/dev/null 2>&1 || { printf 'HEIC import requires macOS sips or a PNG/JPEG conversion.\n' >&2; exit 1; }
  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/learning-library-codex.XXXXXX")"
  codex_image="$temp_dir/cover.png"
  sips -s format png "$photo_path" --out "$codex_image" >/dev/null
fi

result_file="$(mktemp "${TMPDIR:-/tmp}/learning-library-codex-result.XXXXXX")"
log_file="$(mktemp "${TMPDIR:-/tmp}/learning-library-codex-log.XXXXXX")"
trap 'rm -f "$result_file" "$log_file"; cleanup' EXIT

if ! codex exec --ephemeral --sandbox read-only -C "$ROOT_DIR" \
  --image "$codex_image" \
  --output-schema "$SCHEMA" \
  --output-last-message "$result_file" \
  'Identify the book shown on this cover. Return only the schema fields. Use the clearest visible title and author. Choose the single best matching topic. If a field is not readable, return "unknown" for it.' </dev/null >/dev/null 2>"$log_file"; then
  printf 'Codex could not identify that cover. Try a clearer, front-facing image.\n' >&2
  exit 1
fi

title="$(jq -r '.title // "unknown"' "$result_file" | tr '|,' '  ')"
creator="$(jq -r '.creator // "unknown"' "$result_file" | tr '|,' '  ')"
topic="$(jq -r '.topic // "other"' "$result_file")"
printf '%s|%s|%s\n' "$title" "$creator" "$topic"
