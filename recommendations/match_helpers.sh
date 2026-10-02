#!/usr/bin/env bash
# Shared, transparent keyword rules for recommendation scripts.

topic_matches_query() {
  local query="$1"
  local topic="$2"
  case "$topic" in
    ai_ml) [[ "$query" == *"ai"* || "$query" == *"machine learning"* || "$query" == *"artificial intelligence"* ]] ;;
    entrepreneurship) [[ "$query" == *"entrepreneur"* || "$query" == *"startup"* || "$query" == *"strategy"* ]] ;;
    operations_processes) [[ "$query" == *"operations"* || "$query" == *"operation"* || "$query" == *"process"* || "$query" == *"lean"* ]] ;;
    mental_health) [[ "$query" == *"mental"* || "$query" == *"stress"* || "$query" == *"anxiety"* || "$query" == *"therapy"* ]] ;;
    career) [[ "$query" == *"career"* || "$query" == *"product"* || "$query" == *"pm "* || "$query" == pm* || "$query" == *"coding"* || "$query" == *"interview"* ]] ;;
    climbing) [[ "$query" == *"climb"* || "$query" == *"boulder"* || "$query" == *"rumney"* || "$query" == *"squamish"* ]] ;;
    physiology_health) [[ "$query" == *"physiology"* || "$query" == *"physical therapy"* || "$query" == *"exercise"* || "$query" == *"health"* ]] ;;
    economics) [[ "$query" == *"economic"* || "$query" == *"money"* || "$query" == *"finance"* ]] ;;
    fiction) [[ "$query" == *"fiction"* || "$query" == *"novel"* || "$query" == *"story"* ]] ;;
    *) return 1 ;;
  esac
}

query_has_topic_signal() {
  local query="$1"
  local topic
  for topic in ai_ml entrepreneurship operations_processes mental_health career climbing physiology_health economics fiction; do
    topic_matches_query "$query" "$topic" && return 0
  done
  return 1
}

primary_topic_for_query() {
  local query="$1"
  local topic
  for topic in ai_ml entrepreneurship operations_processes mental_health career climbing physiology_health economics fiction; do
    if topic_matches_query "$query" "$topic"; then
      printf '%s\n' "$topic"
      return 0
    fi
  done
  return 1
}

# The Discovery Agent uses this map to make a deliberate stretch beyond the
# topic the user named, while staying within the user's wider learning life.
adjacent_topics_for() {
  case "$1" in
    ai_ml) printf '%s\n' entrepreneurship operations_processes ;;
    entrepreneurship) printf '%s\n' economics career ;;
    operations_processes) printf '%s\n' ai_ml entrepreneurship ;;
    mental_health) printf '%s\n' physiology_health career ;;
    career) printf '%s\n' entrepreneurship mental_health ;;
    climbing) printf '%s\n' physiology_health mental_health ;;
    physiology_health) printf '%s\n' climbing mental_health ;;
    economics) printf '%s\n' entrepreneurship operations_processes ;;
    fiction) printf '%s\n' career mental_health ;;
  esac
}
