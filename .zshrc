HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
ZSH_CONFIG="${HOME}/.config/zsh"
ANTIGEN_DIR="$ZSH_CONFIG/antigen"
DISABLE_AUTO_TITLE=true

bindkey -e # emacs key bindings
source "$ZSH_CONFIG/aliases.zsh"
source "$ZSH_CONFIG/antigen.zsh"

antigen use oh-my-zsh
antigen bundle git
antigen bundle git-extras
antigen bundle npm

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen theme $ZSH_CONFIG soyuka
antigen apply

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
zstyle :compinstall filename '/home/soyuka/.zshrc'
plugins=(zsh-completions colored-man-pages)
autoload -U compinit
compinit

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(zoxide init zsh)"
# corepack enable

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/soyuka/.lmstudio/bin"
source /etc/profile.d/google-cloud-cli.sh

# Scaleway CLI autocomplete initialization.
eval "$(scw autocomplete script shell=zsh)"


# bun completions
[ -s "/home/soyuka/.bun/_bun" ] && source "/home/soyuka/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Piper TTS — speak text via speakers
# Override voice with: SAY_VOICE=en_US-amy-medium say "..."
say() {
  local voice="${SAY_VOICE:-en_US-ljspeech-high}"
  echo "$*" | piper-tts --quiet \
    --model "$HOME/.local/share/piper-voices/${voice}.onnx" \
    --output-raw 2>/dev/null \
    | aplay -q -r 22050 -f S16_LE -t raw -
}

export GITHUB_PERSONAL_ACCESS_TOKEN=$(gh auth token)
