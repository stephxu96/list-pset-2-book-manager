#!/usr/bin/env bash
# Live model agent: uses completed library history as personalization evidence.

set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec bash "$ROOT_DIR/recommendations/run_live_recommender.sh" history
