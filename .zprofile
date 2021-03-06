export EDITOR='vim'
export ANDROID_HOME="${HOME}/Android/Sdk"
# rust, andoid, composer global and local, then local node
export PATH="$PATH:$HOME/.cargo/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$HOME/.composer/vendor/bin:vendor/bin:node_modules/.bin:$HOME/.local/bin:$HOME/.yarn/bin:$HOME/go/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:/usr/lib/emsdk/upstream/emscripten"
# nvm, node
export NVM_DIR="${HOME}/.nvm"
export NVM_LAZY_LOAD=true
export PATH="$HOME/.symfony/bin:$PATH"
export GRIM_DEFAULT_DIR=~/Pictures/Screenshots
export MOZ_ENABLE_WAYLAND=1
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland

# startx on the 1st vt
if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
  # exec startx
  exec sway
fi
