#!/bin/bash
set -euo pipefail

from=$(cat ~/.config/sway/current_scheme)

if [ "$from" = "black" ]; then
    to=white
    theme=light
    signal=USR2
    sed -i -e 's/background = "dark"/background = "light"/' ~/.config/nvim/init.lua
else
    to=black
    theme=dark
    signal=USR1
    sed -i -e 's/background = "light"/background = "dark"/' ~/.config/nvim/init.lua
fi

# foot 1.27 keeps BOTH palettes loaded ([colors-dark] + [colors-light]) and switches between them
# on SIGUSR1 (dark) / SIGUSR2 (light). It never re-reads its config on a signal, so the old
# alacritty-style include-swap silently did nothing — that is why the toggle stopped working.
# -x: unanchored `pkill foot` would also hit footclient.
pkill -x -"$signal" foot || true

# Signals only reach already-running windows. This makes new ones open in the same theme.
sed -i -e "s/^initial-color-theme=.*/initial-color-theme=$theme/" ~/.config/foot/foot.ini

# Claude Code's theme was "dark-ansi", which drew its whole UI from the 16 ANSI slots and so
# followed this toggle for free — at the cost of colliding with the terminal palette (its prompt
# background landed on ANSI 7/8). It is now the truecolor "dark"/"light" theme, which is
# self-contained and therefore does NOT follow the toggle on its own, hence this rewrite.
# Only the value is touched, so the rest of settings.json is untouched. Running sessions keep
# their current theme until restarted; /theme switches one on the spot.
python3 - "$theme" <<'PY' || true
import json, sys, pathlib
p = pathlib.Path.home() / ".claude/settings.json"
try:
    cfg = json.loads(p.read_text())
except Exception:
    sys.exit(0)
if cfg.get("theme") in ("dark", "light"):
    cfg["theme"] = sys.argv[1]
    p.write_text(json.dumps(cfg, indent=2) + "\n")
PY

# tmux's status bar is painted on the terminal background, so the active-window chip needs a
# background per theme or it stops reading as a highlight (#4b5263 is 1.44:1 on 282c34). Values
# must stay in sync with the if-shell fallback in ~/.tmux.conf. No-op when no server is running.
if [ "$theme" = dark ]; then chip=5c6370; else chip=4b5263; fi
tmux set-option -g window-status-current-style "fg=#ffffff,bg=#$chip,bold" 2>/dev/null || true

echo "$to" > ~/.config/sway/current_scheme
