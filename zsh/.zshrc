# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ------------------------------------------------------------------------------
# PATH Configuration (consolidated)
# ------------------------------------------------------------------------------
typeset -U PATH  # Remove duplicates automatically

export PNPM_HOME="/Users/patrikpersson/Library/pnpm"
export BUN_INSTALL="$HOME/.bun"

path=(
  /opt/homebrew/opt/llvm/bin
  /opt/homebrew/opt/postgresql@17/bin
  $HOME/.local/bin
  $BUN_INSTALL/bin
  $PNPM_HOME
  "$HOME/Library/Application Support/Coursier/bin"
  $path
)

# ------------------------------------------------------------------------------
# Oh My Zsh Configuration
# ------------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
HYPHEN_INSENSITIVE="true"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ------------------------------------------------------------------------------
# History Configuration
# ------------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY

# ------------------------------------------------------------------------------
# Zsh Options
# ------------------------------------------------------------------------------
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
setopt EXTENDED_GLOB
setopt NO_BEEP

# ------------------------------------------------------------------------------
# Completion
# ------------------------------------------------------------------------------
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'

# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------
export EDITOR='nvim'
export VISUAL="$EDITOR"

export FORCE_AUTO_BACKGROUND_TASKS=1
export ENABLE_BACKGROUND_TASKS=1
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------
alias pcat='pygmentize -f terminal256 -O style=native -g'

alias ll='ls -lah'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias md='mkdir -p'
alias rd='rmdir'
alias g='git'

alias zshrc='$EDITOR ~/.zshrc'
alias reload='source ~/.zshrc'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ------------------------------------------------------------------------------
# Tool Integrations
# ------------------------------------------------------------------------------
# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Zoxide
eval "$(zoxide init zsh)"

# Google Cloud SDK
source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"
source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"

# Bun completions
[ -s "/Users/patrikpersson/.bun/_bun" ] && source "/Users/patrikpersson/.bun/_bun"

# Carapace
source <(carapace _carapace)

# ------------------------------------------------------------------------------
# Local configuration (secrets, machine-specific settings)
# This file is gitignored - create it manually on each machine
# ------------------------------------------------------------------------------
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
