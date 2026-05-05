#!/usr/bin/env bash
set -e

PASS=0
FAIL=0

mkdir -p ./volumes/workspace ./volumes/claude ./volumes/gsd

run_test() {
  local name="$1"
  shift
  printf "  %-40s" "$name"
  if output=$("$@" 2>&1); then
    echo "PASS"
    PASS=$((PASS + 1))
  else
    echo "FAIL"
    echo "    $output" | head -5
    FAIL=$((FAIL + 1))
  fi
}

run_test "node --version" \
  docker compose -f compose.example.yml run --rm -T --entrypoint "" claude node --version

run_test "gsd --version" \
  docker compose -f compose.example.yml run --rm -T --entrypoint "" claude gsd --version

run_test "claude --version" \
  docker compose -f compose.example.yml run --rm -T --entrypoint "" claude claude --version

run_test "can write to /tmp" \
  docker compose -f compose.example.yml run --rm -T --entrypoint "" claude bash -c "touch /tmp/test && rm /tmp/test"

run_test "can write to /workspace" \
  docker compose -f compose.example.yml run --rm -T --entrypoint "" claude bash -c "touch /workspace/test && rm /workspace/test"

run_test "can write to /home/claude/.claude" \
  docker compose -f compose.example.yml run --rm -T --entrypoint "" claude bash -c "touch /home/claude/.claude/test && rm /home/claude/.claude/test"

run_test "can write to /home/claude/.gsd" \
  docker compose -f compose.example.yml run --rm -T --entrypoint "" claude bash -c "touch /home/claude/.gsd/test && rm /home/claude/.gsd/test"

run_test "cannot write to root filesystem" \
  bash -c '! docker compose -f compose.example.yml run --rm -T --entrypoint "" claude bash -c "touch /usr/local/hack"'

run_test "cannot escalate privileges" \
  bash -c '! docker compose -f compose.example.yml run --rm -T --entrypoint "" claude bash -c "sudo echo test"'

echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
