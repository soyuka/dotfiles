#!/usr/bin/env bash
# Self-contained test for ~/.local/bin/claude-tmux-state.
#
# Runs entirely against an isolated tmux server (-L teststrip) so it never
# touches the user's live server. The script under test is made to target
# that server via the CLAUDE_TMUX_SOCKET testability seam — every invocation
# below sets it explicitly. Do NOT remove that env var from any call: this
# shell's own ambient TMUX_PANE/TMUX point at the real live session, and
# without the seam the script would fall back to plain `tmux`, which resolves
# via $TMUX straight to the live server.
set -u

SCRIPT="$HOME/.local/bin/claude-tmux-state"
SOCK="teststrip"

cleanup() { tmux -L "$SOCK" kill-server >/dev/null 2>&1; }
trap cleanup EXIT

tmux -L "$SOCK" -f /dev/null new-session -d -x 80 -y 24 >/dev/null 2>&1
PANE="$(tmux -L "$SOCK" list-panes -a -F '#{pane_id}' | head -1)"
if [ -z "$PANE" ]; then
  echo "FAIL: could not create isolated test pane"
  exit 1
fi

PASS=0
FAIL=0

run_hook() {
  # $1 = json payload on stdin. Always pinned to the isolated server.
  CLAUDE_TMUX_SOCKET="$SOCK" TMUX_PANE="$PANE" "$SCRIPT" <<<"$1"
}

state() {
  tmux -L "$SOCK" display -p -t "$PANE" '#{@agent_state}' 2>/dev/null
}

since() {
  tmux -L "$SOCK" display -p -t "$PANE" '#{@agent_since}' 2>/dev/null
}

reset_state() {
  tmux -L "$SOCK" set -p -t "$PANE" -u @agent_state >/dev/null 2>&1
  tmux -L "$SOCK" set -p -t "$PANE" -u @agent_since >/dev/null 2>&1
}

check() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$actual" = "$expected" ]; then
    PASS=$((PASS + 1))
    echo "PASS: $desc"
  else
    FAIL=$((FAIL + 1))
    echo "FAIL: $desc (expected '$expected', got '$actual')"
  fi
}

# --- table-driven state transitions ----------------------------------------

reset_state
run_hook '{"hook_event_name":"SessionStart"}'
check "SessionStart -> idle" "idle" "$(state)"

reset_state
run_hook '{"hook_event_name":"UserPromptSubmit"}'
check "UserPromptSubmit -> running" "running" "$(state)"
now="$(date +%s)"
got_since="$(since)"
if [ -n "$got_since" ] && [ "$got_since" -ge $((now - 5)) ] && [ "$got_since" -le "$now" ]; then
  PASS=$((PASS + 1)); echo "PASS: @agent_since set to current epoch on state change"
else
  FAIL=$((FAIL + 1)); echo "FAIL: @agent_since not plausible (got '$got_since', now '$now')"
fi

reset_state
run_hook '{"hook_event_name":"PermissionRequest"}'
check "PermissionRequest -> perm" "perm" "$(state)"

reset_state
run_hook '{"hook_event_name":"Notification","message":"Claude is waiting for your input"}'
check "Notification (waiting for your input) -> done" "done" "$(state)"

reset_state
run_hook '{"hook_event_name":"Notification","message":"Tool use needs your approval"}'
check "Notification (other) -> perm" "perm" "$(state)"

reset_state
run_hook '{"hook_event_name":"Stop"}'
check "Stop -> done" "done" "$(state)"

# SessionEnd must clear the option (empty read-back), not just blank it.
tmux -L "$SOCK" set -p -t "$PANE" @agent_state "running" >/dev/null 2>&1
run_hook '{"hook_event_name":"SessionEnd"}'
check "SessionEnd clears @agent_state" "" "$(state)"

# Unknown event: no-op, exit 0, existing state untouched.
tmux -L "$SOCK" set -p -t "$PANE" @agent_state "idle" >/dev/null 2>&1
run_hook '{"hook_event_name":"SomeFutureEvent"}'
noop_rc=$?
check "unknown event -> state untouched" "idle" "$(state)"
if [ "$noop_rc" -eq 0 ]; then
  PASS=$((PASS + 1)); echo "PASS: unknown event exits 0"
else
  FAIL=$((FAIL + 1)); echo "FAIL: unknown event exit code was $noop_rc"
fi

# No TMUX_PANE in the environment: must exit 0 and emit nothing, and must
# NOT fall back to touching any server. TMUX_PANE explicitly unset here
# (this shell's ambient TMUX_PANE is the LIVE pane — never let it leak in).
reset_state
out="$(env -u TMUX_PANE CLAUDE_TMUX_SOCKET="$SOCK" "$SCRIPT" <<<'{"hook_event_name":"UserPromptSubmit"}' 2>&1)"
rc=$?
if [ "$rc" -eq 0 ] && [ -z "$out" ]; then
  PASS=$((PASS + 1)); echo "PASS: no TMUX_PANE -> exit 0, silent"
else
  FAIL=$((FAIL + 1)); echo "FAIL: no TMUX_PANE -> exit 0, silent (rc=$rc, out='$out')"
fi

echo
echo "Summary: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
