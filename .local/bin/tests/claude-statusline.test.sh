#!/usr/bin/env bash
# Self-contained test for ~/.claude/statusline.sh (single-line output).
set -u

SCRIPT="$HOME/.claude/statusline.sh"
mkdir -p "$HOME/.cache"
DIR="$(mktemp -d "$HOME/.cache/claude-statusline-test.XXXXXX")"
trap 'rm -rf "$DIR"' EXIT
mkdir -p "$DIR/sessions"
printf '{"five_hour":{"utilization":14.0,"resets_at":"2026-11-12T11:20:00+00:00"},"seven_day":{"utilization":40.0,"resets_at":"2026-11-16T00:00:00+00:00"}}' > "$DIR/cache.json"

PASS=0
FAIL=0

ok() { PASS=$((PASS + 1)); }
bad() { FAIL=$((FAIL + 1)); echo "FAIL: $1"; }

INPUT='{"model":{"display_name":"Opus 4.7"},"effort":{"level":"high"},"session_id":"abc","context_window":{"context_window_size":1000000,"current_usage":{"input_tokens":1000,"cache_creation_input_tokens":200000,"cache_read_input_tokens":0}}}'

OUT="$(CLAUDE_SESSIONS_DIR="$DIR/sessions" CLAUDE_USAGE_CACHE="$DIR/cache.json" bash "$SCRIPT" <<<"$INPUT")"
PLAIN="$(printf '%s' "$OUT" | sed 's/\x1b\[[0-9;]*m//g')"

[ "$(printf '%s\n' "$OUT" | wc -l)" -eq 1 ] && ok || bad "exactly one line"
case "$PLAIN" in *"Opus 4.7"*) ok ;; *) bad "model" ;; esac
case "$PLAIN" in *"effort:high"*) ok ;; *) bad "effort" ;; esac
case "$PLAIN" in *"201k/1.0m"*) ok ;; *) bad "tokens 201k/1.0m (got: $PLAIN)" ;; esac
case "$PLAIN" in *"20%"*) ok ;; *) bad "pct" ;; esac
for w in "current:" "weekly:" "resets"; do
  case "$PLAIN" in *"$w"*) bad "must not contain $w" ;; *) ok ;; esac
done
case "$PLAIN" in *"| ") bad "trailing separator" ;; *) ok ;; esac

run() { CLAUDE_SESSIONS_DIR="$DIR/sessions" CLAUDE_USAGE_CACHE="$DIR/cache.json" bash "$SCRIPT" <<<"$1" | sed 's/\x1b\[[0-9;]*m//g'; }

VIM_INPUT='{"model":{"display_name":"Opus 4.7"},"vim":{"mode":"INSERT"},"session_id":"abc","context_window":{"context_window_size":1000000,"current_usage":{"input_tokens":1000}}}'
WITH="$(run "$VIM_INPUT")"
case "$WITH" in "INSERT | Opus 4.7"*) ok ;; *) bad "vim segment first (got: $WITH)" ;; esac
case "$WITH" in *"1k/1.0m 0%") ok ;; *) bad "tokens segment last (got: $WITH)" ;; esac

WITHOUT="$(run "$INPUT")"
case "$WITHOUT" in "Opus 4.7"*) ok ;; *) bad "no vim segment when absent (got: $WITHOUT)" ;; esac

echo "pass=$PASS fail=$FAIL"
[ "$FAIL" -eq 0 ]
