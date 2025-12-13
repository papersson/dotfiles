#!/usr/bin/env bash
set -euo pipefail

# Dotfiles installer
# Creates symlinks from home directory to dotfiles repo

DOTFILES="$HOME/dotfiles"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; }

backup_and_link() {
    local src="$1"
    local dest="$2"

    if [[ -e "$dest" && ! -L "$dest" ]]; then
        warn "Backing up existing $dest to ${dest}.backup"
        mv "$dest" "${dest}.backup"
    elif [[ -L "$dest" ]]; then
        rm "$dest"
    fi

    ln -s "$src" "$dest"
    info "Linked $dest -> $src"
}

# Zsh files
info "Setting up Zsh..."
backup_and_link "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
backup_and_link "$DOTFILES/zsh/.zprofile" "$HOME/.zprofile"
backup_and_link "$DOTFILES/zsh/.zshenv" "$HOME/.zshenv"
backup_and_link "$DOTFILES/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

# Git
info "Setting up Git..."
backup_and_link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

# Create .config if needed
mkdir -p "$HOME/.config"

# Neovim
info "Setting up Neovim..."
backup_and_link "$DOTFILES/config/nvim" "$HOME/.config/nvim"

# Tmux
info "Setting up Tmux..."
mkdir -p "$HOME/.config/tmux"
backup_and_link "$DOTFILES/config/tmux/.tmux.conf" "$HOME/.config/tmux/.tmux.conf"

# Ghostty
info "Setting up Ghostty..."
mkdir -p "$HOME/.config/ghostty"
backup_and_link "$DOTFILES/config/ghostty/config" "$HOME/.config/ghostty/config"

# Helix
info "Setting up Helix..."
backup_and_link "$DOTFILES/config/helix" "$HOME/.config/helix"

# Claude Code
info "Setting up Claude Code..."
mkdir -p "$HOME/.claude"
backup_and_link "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
backup_and_link "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"

# Readline / libedit
info "Setting up Readline..."
backup_and_link "$DOTFILES/readline/.inputrc" "$HOME/.inputrc"
backup_and_link "$DOTFILES/readline/.editrc" "$HOME/.editrc"

# Bin scripts
info "Setting up bin scripts..."
mkdir -p "$HOME/bin"
backup_and_link "$DOTFILES/bin/tmux-sessionizer" "$HOME/bin/tmux-sessionizer"
chmod +x "$HOME/bin/tmux-sessionizer"

echo ""
info "Done! Dotfiles installed."
echo ""
warn "Don't forget to:"
echo "  1. Create ~/.zshrc.local with your API keys (see zsh/.zshrc.local.example)"
echo "  2. Run 'source ~/.zshrc' to reload your shell"
