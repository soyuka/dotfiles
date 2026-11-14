#!/usr/bin/env bash
# Self-contained test for ~/.local/bin/tmux-claude-usage.
set -u

SCRIPT="$HOME/.local/bin/tmux-claude-usage"
mkdir -p "$HOME/.cache"
DIR="$(mktemp -d "$HOME/.cache/tmux-claude-usage-test.XXXXXX")"
trap 'rm -rf "$DIR"' EXIT

PASS=0
FAIL=0

check() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$actual" = "$expected" ]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo "FAIL: $desc"
    echo "  expected: $expected"
    echo "  actual:   $actual"
  fi
}

run() { CLAUDE_USAGE_CACHE="$1" "$SCRIPT"; }

write() { printf '{"five_hour":{"utilization":%s,"resets_at":"%s"},"seven_day":{"utilization":%s,"resets_at":"2026-11-16T00:00:00.209685+00:00"},"extra_usage":{"is_enabled":false}}' "$2" "$3" "$4" > "$1"; }

RESET="2026-11-12T11:20:00.209665+00:00"
HHMM="$(date -d "$RESET" +%H:%M)"

write "$DIR/low.json" 14.0 "$RESET" 40.0
check "low values" '#[fg=green]5h 14% #[fg=green]wk 40% ' "$(run "$DIR/low.json")"

write "$DIR/mid.json" 55.4 "$RESET" 69.6
check "yellow band and rounding" '#[fg=yellow]5h 55% #[fg=colour208]wk 70% ' "$(run "$DIR/mid.json")"

write "$DIR/high.json" 72.0 "$RESET" 10.0
check "5h >=70 shows reset time" "#[fg=colour208]5h 72% ↻${HHMM} #[fg=green]wk 10% " "$(run "$DIR/high.json")"

write "$DIR/crit.json" 95.0 "$RESET" 90.0
check "red at >=90" "#[fg=red]5h 95% ↻${HHMM} #[fg=red]wk 90% " "$(run "$DIR/crit.json")"

write "$DIR/stale.json" 14.0 "$RESET" 40.0
touch -d '20 minutes ago' "$DIR/stale.json"
check "stale file is empty" "" "$(run "$DIR/stale.json")"

check "missing file is empty" "" "$(run "$DIR/absent.json")"

echo 'not json {' > "$DIR/garbage.json"
check "garbage file is empty" "" "$(run "$DIR/garbage.json")"
CLAUDE_USAGE_CACHE="$DIR/garbage.json" "$SCRIPT" >/dev/null 2>&1
check "garbage exit status" "0" "$?"

echo "pass=$PASS fail=$FAIL"
[ "$FAIL" -eq 0 ]
