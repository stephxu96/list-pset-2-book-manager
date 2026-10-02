#!/usr/bin/env bash
# Pipeline cleanup: deduplicate, exclude owned/completed content, polish reasons, cap output.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB="$ROOT_DIR/data/book_database.sh"
seen_file="$(mktemp "${TMPDIR:-/tmp}/learning-library-seen.XXXXXX")"
trap 'rm -f "$seen_file"' EXIT
count=0

while IFS='|' read -r origin reason record || [[ -n "${record:-}" ]]; do
  [[ -z "$record" ]] && continue
  IFS=',' read -r id title creator content_type provider provider_format topic location discipline duration energy status saved_reason link <<< "$record"
  case "$status" in finished|listened|watched) continue ;; esac
  key="$(printf '%s|%s' "$title" "$provider_format" | tr '[:upper:]' '[:lower:]')"
  grep -Fqx "$key" "$seen_file" && continue
  # The required recommendation shortlist contains only new content. Saved-library
  # matches are shown separately by the workflow before this cleanup pipeline.
  if "$DB" exists "$title"; then
    continue
  fi
  printf '%s\n' "$key" >> "$seen_file"
  # Polish display whitespace without replacing the live model's explanation.
  reason="$(printf '%s' "$reason" | tr '\r\t' '  ' | sed 's/[[:space:]][[:space:]]*/ /g; s/^ //; s/ $//')"
  printf '%s|%s|%s\n' "$origin" "$reason" "$record"
  count=$((count + 1))
  if [[ "$count" -ge 5 ]]; then
    break
  fi
done

exit 0
