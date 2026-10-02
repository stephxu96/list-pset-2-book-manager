#!/usr/bin/env bash
# Fast, deterministic checks for Learning Library components.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pass_count=0
fail_count=0

pass() {
  pass_count=$((pass_count + 1))
  printf 'PASS  %s\n' "$1"
}

fail() {
  fail_count=$((fail_count + 1))
  printf 'FAIL  %s\n' "$1" >&2
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  [[ "$haystack" == *"$needle"* ]] || {
    printf 'Expected output to contain: %s\n' "$needle" >&2
    return 1
  }
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  [[ "$haystack" != *"$needle"* ]] || {
    printf 'Expected output not to contain: %s\n' "$needle" >&2
    return 1
  }
}

run() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

test_search_component() {
  local direct piped
  direct="$("$ROOT_DIR/books/search_books.sh" career)"
  piped="$(printf 'career\n' | "$ROOT_DIR/books/search_books.sh")"
  assert_contains "$direct" 'Cracking the PM Career'
  assert_contains "$direct" 'Cracking the PM Interview'
  assert_contains "$piped" 'Becoming'
}

test_search_workflow_normalizes_terminal_return() {
  local output
  output="$(printf 'career\r\n' | env PATH='/usr/bin:/bin' "$ROOT_DIR/workflows/manage_library.sh" search)"
  assert_contains "$output" 'Search results for "career" — 6 match(es)'
  assert_contains "$output" 'Cracking the PM Career'
}

test_metadata_component() {
  local record
  record="$("$ROOT_DIR/books/fetch_book_metadata.sh" 'Example Audio' 'Example Creator' audio Amazon ai_ml want_to_listen class low)"
  assert_contains "$record" ',audio,Amazon,Audible,ai_ml,'
  [[ "$(printf '%s\n' "$record" | awk -F',' '{ print NF }')" == '14' ]]
}

test_request_parser() {
  local climbing career
  climbing="$("$ROOT_DIR/recommendations/parse_request.sh" --query 'I have about 25 minutes and want a low-energy climbing video.')"
  career="$("$ROOT_DIR/recommendations/parse_request.sh" --query 'I need PM career advice in a medium-energy book.')"
  [[ "$climbing" == 'low|video|25' ]]
  [[ "$career" == 'medium|text|' ]]
}

test_discovery_agent() {
  local result
  result="$("$ROOT_DIR/recommendations/recommend_for_discovery.sh" --query 'I have about 25 minutes and want a low-energy climbing video.' --energy low --format video --minutes 25)"
  assert_contains "$result" 'Movement: Functional Range Conditioning'
  assert_contains "$result" 'connects climbing to physiology_health'
  assert_not_contains "$result" 'Climbing Training Fundamentals'
}

test_refinement() {
  local input output
  input=$'discovery|existing|d1,Dune,Frank Herbert,text,Other,Book,fiction,,,,medium,want_to_read,test,\n'
  input+=$'discovery|fresh|d2,Fresh Test Book,Creator,text,Other,Book,ai_ml,,,,medium,want_to_read,test,\n'
  input+=$'discovery|duplicate|d3,Fresh Test Book,Creator,text,Other,Book,ai_ml,,,,medium,want_to_read,test,'
  output="$(printf '%s' "$input" | "$ROOT_DIR/recommendations/refine_recommendations.sh")"
  assert_not_contains "$output" 'Dune'
  [[ "$(printf '%s\n' "$output" | grep -Fc 'Fresh Test Book')" == '1' ]]
}

test_photo_response_contract() {
  local response rows
  command -v jq >/dev/null 2>&1
  response='{"books":[{"title":"Book One","creator":"Author One","topic":"ai_ml"},{"title":"Book Two","creator":"Author Two","topic":"climbing"}]}'
  rows="$(printf '%s\n' "$response" | jq -r '.books[] | [(.title // "unknown"), (.creator // "unknown"), (.topic // "other")] | @tsv' | while IFS=$'\t' read -r title creator topic; do printf '%s|%s|%s\n' "$(printf '%s' "$title" | tr '|,' '  ')" "$(printf '%s' "$creator" | tr '|,' '  ')" "$topic"; done)"
  assert_contains "$rows" 'Book One|Author One|ai_ml'
  assert_contains "$rows" 'Book Two|Author Two|climbing'
}

test_data_integrity() {
  [[ -z "$(awk -F',' 'NF != 14 { print NR }' "$ROOT_DIR/data/books.csv")" ]]
  ! grep -Fq 'The Lean Startup' "$ROOT_DIR/data/books.csv"
}

run 'search component supports direct and piped input' test_search_component
run 'search workflow normalizes terminal input' test_search_workflow_normalizes_terminal_return
run 'metadata component creates an Audible CSV record' test_metadata_component
run 'natural-language request parser extracts constraints' test_request_parser
run 'discovery agent returns an adjacent-topic stretch pick' test_discovery_agent
run 'refiner removes owned and duplicate candidates' test_refinement
run 'photo response contract supports multiple detected books' test_photo_response_contract
run 'library CSV has valid rows and no test import' test_data_integrity

printf '\n%s passed; %s failed.\n' "$pass_count" "$fail_count"
[[ "$fail_count" -eq 0 ]]
