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

# Vi-mode configuration (must be set before oh-my-zsh loads)
VI_MODE_SET_CURSOR=true           # Cursor shape: beam (insert) / block (normal)
KEYTIMEOUT=1                      # 10ms escape delay (default 400ms is sluggish)

plugins=(git vi-mode zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ------------------------------------------------------------------------------
# Vi-Mode Keybindings (after oh-my-zsh loads)
# ------------------------------------------------------------------------------
# Prefix-based history search with j/k in command mode
bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-beginning-search-forward

# Arrow keys for prefix-based history search (both modes)
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# Ctrl-p/n also do prefix search (more useful than plain up/down)
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward

# Ctrl-u kills to beginning of line (like bash/readline)
bindkey '^U' backward-kill-line

# Ctrl-k kills to end of line
bindkey '^K' kill-line

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
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

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

# fzf - fuzzy finder (Ctrl-r: history, Ctrl-t: files, Alt-c: cd)
if [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/completion.zsh
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi

# fzf styling (gruvbox colors)
export FZF_DEFAULT_OPTS='
  --height=40%
  --layout=reverse
  --border=rounded
  --color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#928374
  --color=fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934
  --color=marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934
'

# Use fd for fzf (faster, respects .gitignore)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# ------------------------------------------------------------------------------
# Local configuration (secrets, machine-specific settings)
# This file is gitignored - create it manually on each machine
# ------------------------------------------------------------------------------
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
