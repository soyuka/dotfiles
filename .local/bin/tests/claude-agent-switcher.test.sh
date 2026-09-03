#!/usr/bin/env bash
# Self-contained test for ~/.local/bin/claude-agent-switcher.
#
# Runs entirely against an isolated tmux server (-L swtest) so it never
# touches the user's live server. The script under test is made to target
# that server via the CLAUDE_TMUX_SOCKET testability seam (same as
# claude-tmux-state.test.sh) — every invocation below sets it explicitly.
#
# fzf is stubbed (captures stdin to a file, exits 130 "cancelled") so the
# switcher runs enumeration + rendering to completion but never actually
# jumps a pane. A logging tmux wrapper sits ahead of the real `tmux` on
# PATH so tests can assert select-pane/select-window were never reached
# after a cancelled fzf. Both stubs are executables and therefore live
# under $HOME (the scratchpad is mounted noexec).
#
# CLAUDE_TMUX_MAP_DIR points the switcher at a fixture map dir instead of
# the real ~/.local/state/claude-tmux-panes.
set -u

SCRIPT="$HOME/.local/bin/claude-agent-switcher"
SOCK="swtest"
REAL_TMUX="$(command -v tmux)"

D="$(mktemp -d "$HOME/.cache/swtest-bin-XXXXXX")"
MAPDIR="$(mktemp -d "$HOME/.cache/swtest-map-XXXXXX")"
WORKDIR="$(mktemp -d "$HOME/.cache/swtest-work-XXXXXX")"

cleanup() {
  "$REAL_TMUX" -L "$SOCK" kill-server >/dev/null 2>&1
  rm -rf "$D" "$MAPDIR" "$WORKDIR"
}
trap cleanup EXIT

PASS=0
FAIL=0

check() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$actual" = "$expected" ]; then
    PASS=$((PASS + 1)); echo "PASS: $desc"
  else
    FAIL=$((FAIL + 1)); echo "FAIL: $desc (expected '$expected', got '$actual')"
  fi
}

check_contains() {
  local desc="$1" needle="$2" haystack="$3"
  case "$haystack" in
    *"$needle"*) PASS=$((PASS + 1)); echo "PASS: $desc" ;;
    *) FAIL=$((FAIL + 1)); echo "FAIL: $desc (expected output to contain '$needle', got: $haystack)" ;;
  esac
}

check_not_contains() {
  local desc="$1" needle="$2" haystack="$3"
  case "$haystack" in
    *"$needle"*) FAIL=$((FAIL + 1)); echo "FAIL: $desc (expected output to NOT contain '$needle')" ;;
    *) PASS=$((PASS + 1)); echo "PASS: $desc" ;;
  esac
}

# --- fake `claude` binary: real `sleep`, renamed, so pane_current_command
# matches claude* without actually running claude. ---
cp "$(command -v sleep)" "$D/claude"

# --- fzf stub: capture stdin verbatim, then behave as a cancelled fzf. ---
cat >"$D/fzf" <<'STUB'
#!/usr/bin/env bash
cat >"$FZF_CAPTURE"
exit 130
STUB
chmod +x "$D/fzf"

# --- tmux call logger: records every argv the script invokes tmux with,
# then execs the real binary so the isolated server still does the work. ---
cat >"$D/tmux" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >>"\$TMUX_CALL_LOG"
exec "$REAL_TMUX" "\$@"
EOF
chmod +x "$D/tmux"

"$REAL_TMUX" -L "$SOCK" new-session -d -x 200 -y 50 -s main >/dev/null 2>&1

# pane 0 (default shell): non-claude pane, must be excluded.
PANE_OTHER="$(REAL="$REAL_TMUX" "$REAL_TMUX" -L "$SOCK" list-panes -t main -F '#{pane_id}' | head -1)"

# three claude panes.
PANE_RUN="$("$REAL_TMUX" -L "$SOCK" split-window -t main -P -F '#{pane_id}' "$D/claude 300")"
PANE_UNKNOWN="$("$REAL_TMUX" -L "$SOCK" split-window -t main -P -F '#{pane_id}' "$D/claude 300")"
PANE_NOMAP="$("$REAL_TMUX" -L "$SOCK" split-window -t main -P -F '#{pane_id}' "$D/claude 300")"

"$REAL_TMUX" -L "$SOCK" set-option -p -t "$PANE_RUN" @agent_state running >/dev/null 2>&1
# PANE_UNKNOWN: @agent_state deliberately left unset (empty) — the
# regression case for the \x1f/IFS field-collapse bug.
# PANE_NOMAP: state set, but no map fixture entry will be created for it.
"$REAL_TMUX" -L "$SOCK" set-option -p -t "$PANE_NOMAP" @agent_state idle >/dev/null 2>&1

"$REAL_TMUX" -L "$SOCK" select-pane -t "$PANE_RUN" -T "RUNTITLE" >/dev/null 2>&1
"$REAL_TMUX" -L "$SOCK" select-pane -t "$PANE_UNKNOWN" -T "UNKNOWNTITLE" >/dev/null 2>&1
"$REAL_TMUX" -L "$SOCK" select-pane -t "$PANE_NOMAP" -T "NOMAPTITLE" >/dev/null 2>&1

# --- fixture transcript (valid tail + one deliberately malformed line) ---
TRANSCRIPT="$WORKDIR/fixture.jsonl"
cat >"$TRANSCRIPT" <<'JSONL'
{"type":"user","message":{"content":[{"type":"text","text":"hi"}]}}
not valid json at all {{{
{"type":"assistant","message":{"content":[{"type":"thinking","text":"pondering"}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash","input":{}}]}}
{"type":"assistant","message":{"content":[{"type":"text","text":"Final answer here"}]}}
JSONL

FULL_UUID="aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
printf '%s\t%s\n' "$FULL_UUID" "$TRANSCRIPT" >"$MAPDIR/${PANE_RUN#%}"
printf '%s\t%s\n' "11111111-2222-3333-4444-555555555555" "$TRANSCRIPT" >"$MAPDIR/${PANE_UNKNOWN#%}"
# no map file at all for PANE_NOMAP.

# transcript that doesn't exist, for the preview degrade test.
MISSING_UUID="99999999-8888-7777-6666-555544443333"
printf '%s\t%s\n' "$MISSING_UUID" "$WORKDIR/does-not-exist.jsonl" >"$MAPDIR/${PANE_NOMAP#%}.missingtranscript"

run_switcher() {
  # $1 = capture file for fzf's stdin (the rendered menu).
  FZF_CAPTURE="$1" PATH="$D:$PATH" CLAUDE_TMUX_SOCKET="$SOCK" \
    CLAUDE_TMUX_MAP_DIR="$MAPDIR" TMUX_CALL_LOG="$WORKDIR/tmux.log" \
    "$SCRIPT"
}

# row_for <needle-title> <menu-file>: the single tab-delimited raw line
# whose title column contains $needle, with the leading "pane_id\t" and
# the target column's own padding stripped, split on runs of 2+ spaces
# (columns are always separated by >=2 literal spaces; word_for values
# like "needs you" use a single internal space and must survive intact).
# ANSI colour is stripped here so every field assertion below compares
# VISIBLE text: the status column is colour-wrapped after padding, and the
# escapes would otherwise land inside field 3.
row_for() {
  local needle="$1" menu="$2"
  grep -- "$needle" "$menu" | cut -f2- | sed 's/\x1b\[[0-9;]*m//g'
}

field() {
  # $1 = row (post cut -f2-), $2 = 1-based column index after splitting
  # on runs of 2+ spaces.
  printf '%s' "$1" | awk -F'  +' -v i="$2" '{print $i}'
}

# =============================================================================
echo "--- enumeration + rendering ---"

CAP1="$WORKDIR/cap1"
run_switcher "$CAP1" >"$WORKDIR/stdout1" 2>"$WORKDIR/stderr1"
RC1=$?
check "cancelled fzf -> script exits 0" "0" "$RC1"

MENU="$CAP1"

row_run="$(row_for RUNTITLE "$MENU")"
row_unknown="$(row_for UNKNOWNTITLE "$MENU")"
row_nomap="$(row_for NOMAPTITLE "$MENU")"

check "populated @agent_state (running) -> status column" "… working" "$(field "$row_run" 3)"
check "empty @agent_state -> status column (regression: \\x1f delimiter)" "○ standing by" "$(field "$row_unknown" 3)"
check "empty @agent_state pane still appears in menu" "yes" "$([ -n "$row_unknown" ] && echo yes || echo no)"

check "session short id = first 8 chars of map field 1" "aaaaaaaa" "$(field "$row_run" 4)"
check "missing map entry -> '-' for age" "-" "$(field "$row_nomap" 2)"
check "missing map entry -> '-' for short id" "-" "$(field "$row_nomap" 4)"

check_not_contains "non-claude pane excluded from menu" "$PANE_OTHER" "$(cat "$MENU")"

check "no crash: script produced stderr" "" "$(cat "$WORKDIR/stderr1")"

check_not_contains "cancelled fzf performs no select-pane" "select-pane" "$(cat "$WORKDIR/tmux.log" 2>/dev/null)"
check_not_contains "cancelled fzf performs no select-window" "select-window" "$(cat "$WORKDIR/tmux.log" 2>/dev/null)"

# =============================================================================
echo "--- no live claude panes ---"

"$REAL_TMUX" -L "$SOCK" kill-session -t main >/dev/null 2>&1
"$REAL_TMUX" -L "$SOCK" new-session -d -x 200 -y 50 -s empty >/dev/null 2>&1

CAP2="$WORKDIR/cap2"
out_empty="$(run_switcher "$CAP2" 2>"$WORKDIR/stderr2")"
rc_empty=$?
check "no claude panes -> message" "No live Claude Code panes found." "$out_empty"
check "no claude panes -> exit 0" "0" "$rc_empty"

# =============================================================================
echo "--- preview ---"

preview_out="$(PATH="$D:$PATH" CLAUDE_TMUX_SOCKET="$SOCK" CLAUDE_TMUX_MAP_DIR="$MAPDIR" \
  "$SCRIPT" --preview-pane "$PANE_RUN" 2>&1)"
preview_rc=$?

check "preview exits 0" "0" "$preview_rc"
check_contains "preview shows full session UUID" "$FULL_UUID" "$preview_out"
check_contains "preview shows resume command" "claude --resume $FULL_UUID" "$preview_out"
check_contains "preview parses last assistant text from transcript tail" "Final answer here" "$preview_out"
check_contains "preview parses last tool used from transcript tail" "Bash" "$preview_out"

# missing/malformed transcript degrade path: point at PANE_NOMAP's second
# (unused-by-menu) map entry, whose transcript file does not exist.
missing_map="$MAPDIR/${PANE_NOMAP#%}"
cp "$MAPDIR/${PANE_NOMAP#%}.missingtranscript" "$missing_map"
preview_missing="$(PATH="$D:$PATH" CLAUDE_TMUX_SOCKET="$SOCK" CLAUDE_TMUX_MAP_DIR="$MAPDIR" \
  "$SCRIPT" --preview-pane "$PANE_NOMAP" 2>&1)"
preview_missing_rc=$?
check "preview with missing transcript exits 0 (no crash)" "0" "$preview_missing_rc"
check_contains "preview with missing transcript shows fallback string" "(no recent activity parsed)" "$preview_missing"

check "preview for a pane with no map entry at all exits 0" "0" \
  "$(PATH="$D:$PATH" CLAUDE_TMUX_SOCKET="$SOCK" CLAUDE_TMUX_MAP_DIR="$MAPDIR" "$SCRIPT" --preview-pane "%99999" >/dev/null 2>&1; echo $?)"

echo
echo "Summary: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
