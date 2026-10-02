#!/usr/bin/env bash
# Live model agent: explores an adjacent topic using the discovery catalog.

set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec bash "$ROOT_DIR/recommendations/run_live_recommender.sh" discovery
