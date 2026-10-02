#!/usr/bin/env bash
# Converts terminal drag-and-drop path text into a filesystem path.

set -euo pipefail

[[ $# -eq 1 ]] || { printf 'Usage: %s dropped-path\n' "$0" >&2; exit 2; }

path="${1//$'\r'/}"
path="$(printf '%s' "$path" | sed \
  -e 's/^[[:space:]]*//' \
  -e 's/[[:space:]]*$//' \
  -e 's/^"//' \
  -e 's/"$//' \
  -e "s/^'//" \
  -e "s/'$//")"
path="${path#file://localhost}"
path="${path#file://}"

# Finder/Terminal and pasted rich text can escape punctuation and append ASCII
# whitespace or a non-breaking space. Remove those artifacts before file access.
path="$(printf '%s' "$path" | sed \
  -e 's/\\ / /g' \
  -e 's/\\_/_/g' \
  -e 's/^[[:space:]]*//' \
  -e 's/[[:space:]]*$//' \
  -e 's/ *$//' \
  -e 's/%20/ /g' \
  -e 's/%5[Ff]/_/g')"

printf '%s\n' "$path"
