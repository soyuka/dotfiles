HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
ZSH_CONFIG="${HOME}/.config/zsh"
ANTIGEN_DIR="$ZSH_CONFIG/antigen"
fpath+=~/.zfunc

bindkey -e # emacs key bindings
source "$ZSH_CONFIG/aliases.zsh"
source "$ZSH_CONFIG/antigen.zsh"

antigen use oh-my-zsh
antigen bundle git
antigen bundle git-extras
antigen bundle npm

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen bundle rupa/z
antigen bundle lukechilds/zsh-nvm
antigen theme $ZSH_CONFIG soyuka
antigen apply

zstyle :compinstall filename '/home/soyuka/.zshrc'
plugins=(zsh-completions)
autoload -U compinit
compinit

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
