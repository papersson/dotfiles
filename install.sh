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
mkdir -p "$HOME/.config/git"
backup_and_link "$DOTFILES/git/ignore" "$HOME/.config/git/ignore"

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
backup_and_link "$DOTFILES/config/ghostty/themes" "$HOME/.config/ghostty/themes"

# Helix
info "Setting up Helix..."
backup_and_link "$DOTFILES/config/helix" "$HOME/.config/helix"

# Atuin
info "Setting up Atuin..."
mkdir -p "$HOME/.config/atuin"
backup_and_link "$DOTFILES/config/atuin/config.toml" "$HOME/.config/atuin/config.toml"

# Claude Code
info "Setting up Claude Code..."
mkdir -p "$HOME/.claude"
backup_and_link "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
backup_and_link "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"

# Readline / libedit
info "Setting up Readline..."
backup_and_link "$DOTFILES/readline/.inputrc" "$HOME/.inputrc"
backup_and_link "$DOTFILES/readline/.editrc" "$HOME/.editrc"

# Ripgrep
info "Setting up Ripgrep..."
backup_and_link "$DOTFILES/ripgrep/.ripgreprc" "$HOME/.ripgreprc"

# Bin scripts
info "Setting up bin scripts..."
mkdir -p "$HOME/bin"
backup_and_link "$DOTFILES/bin/tmux-sessionizer" "$HOME/bin/tmux-sessionizer"
chmod +x "$HOME/bin/tmux-sessionizer"

echo ""
info "Done! Dotfiles installed."
echo ""
warn "Next steps:"
echo "  1. Install packages:        brew bundle --file=$DOTFILES/Brewfile"
echo "  2. Configure macOS:         $DOTFILES/macos/defaults.sh"
echo "  3. Create local secrets:    cp $DOTFILES/zsh/.zshrc.local.example ~/.zshrc.local"
echo "  4. Reload shell:            source ~/.zshrc"
