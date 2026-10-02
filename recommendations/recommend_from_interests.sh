#!/usr/bin/env bash
# Live model agent: ranks saved library items against the request and interests.

set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec bash "$ROOT_DIR/recommendations/run_live_recommender.sh" interests
