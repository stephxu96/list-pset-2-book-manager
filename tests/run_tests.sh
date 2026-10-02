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
  local name="$1" status
  shift
  # A function invoked as an if-condition silently disables errexit inside it.
  # Run independently so an early failed assertion cannot be masked later.
  set +e
  ( set -e; "$@" )
  status=$?
  set -e
  if [[ "$status" -eq 0 ]]; then
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
  assert_contains "$output" 'Search results for "career"'
  assert_contains "$output" 'Cracking the PM Career'
}

test_metadata_component() {
  local record
  record="$("$ROOT_DIR/books/fetch_book_metadata.sh" 'Example Audio' 'Example Creator' audio Amazon ai_ml want_to_listen class low)"
  assert_contains "$record" ',audio,Amazon,Audible,ai_ml,'
  [[ "$(printf '%s\n' "$record" | awk -F',' '{ print NF }')" == '14' ]]
}

test_live_agent_validation() {
  local fixture_bin result context
  fixture_bin="$(mktemp -d /tmp/learning-library-mock-codex.XXXXXX)"
  ln -s "$ROOT_DIR/tests/mock_codex.sh" "$fixture_bin/codex"
  context='{"request":"PM career advice","library":[{"id":"a001","title":"Project Hail Mary","status":"want_to_listen","raw":"a001,Project Hail Mary,Andy Weir,audio,Amazon,Audible,fiction,,,,medium,want_to_listen,,"}],"discovery_catalog":[]}'
  result="$(printf '%s\n' "$context" | PATH="$fixture_bin:$PATH" MOCK_RECOMMENDATION_ID=a001 bash "$ROOT_DIR/recommendations/run_live_recommender.sh" interests)"
  rm -rf "$fixture_bin"
  [[ "$result" == *'interests|Mock model match|a001,Project Hail Mary'* ]] || return 1
  # Hallucinated IDs are ignored; records always resolve from the supplied inventory.
  fixture_bin="$(mktemp -d /tmp/learning-library-mock-codex.XXXXXX)"
  ln -s "$ROOT_DIR/tests/mock_codex.sh" "$fixture_bin/codex"
  result="$(printf '%s\n' "$context" | PATH="$fixture_bin:$PATH" MOCK_RECOMMENDATION_ID=fake-id bash "$ROOT_DIR/recommendations/run_live_recommender.sh" interests)"
  rm -rf "$fixture_bin"
  [[ -z "$result" ]]
}

test_dropped_photo_path_normalization() {
  local dropped normalized
  dropped='/Users/stephxu/Documents/1.125/pset\_2\_book\_manager/IMG\_5992.heic '
  normalized="$(bash "$ROOT_DIR/books/normalize_dropped_path.sh" "$dropped")"
  [[ "$normalized" == *'/pset_2_book_manager/IMG_5992.heic' ]] || return 1
  [[ "$normalized" != *$'\u00a0'* ]]
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

test_refinement_polish_and_final_line() {
  local output
  output="$(printf '%s' 'discovery|  A   useful suggestion.  |t1,Unterminated Test Candidate,Creator,text,Other,Book,ai_ml,,,,medium,want_to_read,test,' | "$ROOT_DIR/recommendations/refine_recommendations.sh")"
  assert_contains "$output" 'discovery|A useful suggestion.|t1,'
}

test_refinement_completed_and_limit() {
  local output i
  output="$({
    printf '%s\n' 'discovery|completed|t0,Completed Test Candidate,Creator,video,Other,Video,ai_ml,,,,low,watched,test,'
    for i in 1 2 3 4 5 6; do
      printf 'discovery|fresh|t%s,Limit Test Candidate %s,Creator,text,Other,Book,ai_ml,,,,medium,want_to_read,test,\n' "$i" "$i"
    done
  } | "$ROOT_DIR/recommendations/refine_recommendations.sh")"
  assert_not_contains "$output" 'Completed Test Candidate'
  [[ "$(printf '%s\n' "$output" | wc -l | tr -d ' ')" == 5 ]]
  assert_not_contains "$output" 'Limit Test Candidate 6'
}

test_data_integrity() {
  [[ -z "$(awk -F',' 'NF != 14 { print NR }' "$ROOT_DIR/data/books.csv")" ]]
  [[ -z "$(awk -F',' 'NR > 1 && ($1 == "" || seen[$1]++) { print NR }' "$ROOT_DIR/data/books.csv")" ]]
}

test_add_handles_missing_final_newline() {
  local temp_data header existing record row_count
  temp_data="$(mktemp -d /tmp/learning-library-db-append.XXXXXX)"
  cp "$ROOT_DIR/data/book_database.sh" "$temp_data/book_database.sh"
  header="$(head -n 1 "$ROOT_DIR/data/books.csv")"
  existing="$(sed -n '2p' "$ROOT_DIR/data/books.csv")"
  printf '%s\n%s' "$header" "$existing" > "$temp_data/books.csv"
  record="$("$ROOT_DIR/books/fetch_book_metadata.sh" 'Regression Item' 'Test Author' text Physical other want_to_read curiosity low)"
  "$temp_data/book_database.sh" add "$record"
  row_count="$(wc -l < "$temp_data/books.csv" | tr -d ' ')"
  [[ "$row_count" == 3 ]] || { rm -rf "$temp_data"; return 1; }
  [[ -z "$(awk -F',' 'NF != 14 { print NR }' "$temp_data/books.csv")" ]] || { rm -rf "$temp_data"; return 1; }
  rm -rf "$temp_data"
}

run 'search component supports direct and piped input' test_search_component
run 'search workflow normalizes terminal input' test_search_workflow_normalizes_terminal_return
run 'metadata component creates an Audible CSV record' test_metadata_component
run 'live agent validates model-selected IDs against its inventory' test_live_agent_validation
run 'dropped HEIC path normalization removes terminal escapes and NBSP' test_dropped_photo_path_normalization
run 'refiner removes owned and duplicate candidates' test_refinement
run 'refiner polishes reasons and accepts a final line without newline' test_refinement_polish_and_final_line
run 'refiner excludes completed candidates and caps output at five' test_refinement_completed_and_limit
run 'photo response contract supports multiple detected books' test_photo_response_contract
run 'database append separates records when CSV lacks final newline' test_add_handles_missing_final_newline
run 'library CSV has valid rows and unique nonempty IDs' test_data_integrity

printf '\n%s passed; %s failed.\n' "$pass_count" "$fail_count"
[[ "$fail_count" -eq 0 ]]
