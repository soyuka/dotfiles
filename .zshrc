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

zstyle :compinstall filename '/home/soyuka/.zshrc'
plugins=(zsh-completions colored-man-pages)
autoload -U compinit
compinit

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(zoxide init zsh)"
# corepack enable
# source /usr/share/nvm/init-nvm.sh

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/soyuka/.lmstudio/bin"
source /etc/profile.d/google-cloud-cli.sh
