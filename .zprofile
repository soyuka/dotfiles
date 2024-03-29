export LC_ALL=en_US.UTF-8
export LANG=fr_FR.UTF-8
export EDITOR='vim'
export SQITCH_EDITOR='vim'
export ANDROID_HOME="${HOME}/Android/Sdk"
# rust, andoid, composer global and local, then local node
export PATH="$PATH:$HOME/tesseract:$HOME/.cargo/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$HOME/.composer/vendor/bin:vendor/bin:node_modules/.bin:$HOME/.local/bin:$HOME/.yarn/bin:$HOME/go/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:/usr/lib/emsdk/upstream/emscripten:$HOME/.local/share/gem/ruby/3.0.0/bin:$HOME/.vim/plugged/phpactor/bin"
# nvm, node
export NVM_DIR="${HOME}/.nvm"
export NVM_LAZY_LOAD=true
export PATH="$HOME/.symfony/bin:$PATH"
export GRIM_DEFAULT_DIR=~/Pictures/Screenshots
export MOZ_ENABLE_WAYLAND=1
# export MANPAGER="sh -c 'col -bx | bat -l man -p'" issues with colors
export MANPAGER="less -Rf" issues with colors
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland

export GPG_TTY=$(tty)
# PHPStorm needs that on wayland 
export _JAVA_AWT_WM_NONREPARENTING=1

# Force Mesa3d anisotropy filter
# export RADV_TEX_ANISO=16

# startx on the 1st vt
if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
  # exec startx
  exec sway
fi

