#!/usr/bin/env bash
set -u

SCRIPT="$HOME/.local/bin/tmux-copy-join"
PASS=0
FAIL=0

check() {
  local name="$1" expected="$2" input="$3"; shift 3
  local got
  got="$(printf '%b' "$input" | COPY_JOIN_SINK=cat "$SCRIPT" "$@")"
  if [ "$got" = "$expected" ]; then PASS=$((PASS + 1)); else FAIL=$((FAIL + 1)); printf 'FAIL: %s\n  expected: %q\n  got:      %q\n' "$name" "$expected" "$got"; fi
}

L1="$(printf '%040d' 0)"

check "path cut at full width joins without space" \
  "/tmp/x/${L1}23f2419a/scratchpad/p.pw" \
  "/tmp/x/${L1}23\n  f2419a/scratchpad/p.pw" 60 11 0 20 1

check "prose filling the width keeps a space" \
  "word ${L1}wrapped next line" \
  "word ${L1}wrapped\n  next line" 60 11 0 10 1

check "short line keeps a space" \
  "docker run -v /a:/b image --rm" \
  "docker run -v /a:/b\n  image --rm\n" 60 2 0 10 1

check "backslash continuation kept" \
  "$(printf 'docker run \\\n  --rm image')" \
  "docker run \\\\\n  --rm image" 60 0 0 10 1

check "backward selection uses end as top" \
  "/tmp/x/${L1}23f2419a/p.pw" \
  "/tmp/x/${L1}23\n  f2419a/p.pw" 60 10 5 11 4

check "blank line keeps paragraph break" \
  "$(printf 'para one wrapped\n\npara two')" \
  "para one\n  wrapped\n\n  para two" 60 2 0 10 3

check "whitespace-only lines collapse to one break" \
  "$(printf 'one\n\ntwo')" \
  "one\n  \n  \n  two" 60 2 0 5 3

check "list items keep their line" \
  "$(printf 'Les deux :\n- one wrapped\n- two\n1. three')" \
  "Les deux :\n  - one\n    wrapped\n  - two\n  1. three" 60 2 0 10 4

check "no geometry falls back to spaces" \
  "/tmp/x/${L1}23 f2419a/p.pw" \
  "/tmp/x/${L1}23\n  f2419a/p.pw"

echo "pass=$PASS fail=$FAIL"
[ "$FAIL" -eq 0 ]
