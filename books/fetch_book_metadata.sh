#!/usr/bin/env bash
# Produces a predictable library record from basic input. No storage access.

set -euo pipefail

sanitize() { printf '%s' "$1" | tr ',\n\r|' '    '; }

[[ $# -eq 8 ]] || { printf 'Usage: %s title creator type provider topic status reason energy\n' "$0" >&2; exit 1; }

title="$(sanitize "$1")"
creator="$(sanitize "$2")"
content_type="$(sanitize "$3")"
provider="$(sanitize "$4")"
topic="$(sanitize "$5")"
status="$(sanitize "$6")"
reason="$(sanitize "$7")"
energy="$(sanitize "$8")"

# Stable enough for a personal CSV while avoiding a dependency on uuid tools.
id="user-$(date +%s)-$RANDOM"
case "$provider" in
  Amazon) provider_format="Kindle" ;;
  YouTube) provider_format="YouTube" ;;
  Netflix) provider_format="Netflix" ;;
  Physical) provider_format="Physical" ;;
  GunksApp) provider_format="GunksApp" ;;
  *) provider_format="$provider" ;;
esac
[[ "$content_type" == "audio" && "$provider" == "Amazon" ]] && provider_format="Audible"

# id,title,creator,type,provider,format,topic,location,discipline,duration,energy,status,reason,link
printf '%s,%s,%s,%s,%s,%s,%s,,,,%s,%s,%s,\n' \
  "$id" "$title" "$creator" "$content_type" "$provider" "$provider_format" "$topic" "$energy" "$status" "$reason"
