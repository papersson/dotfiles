#!/usr/bin/env bash
set -euo pipefail

# Dotfiles installer
# Creates symlinks from home directory to dotfiles repo
# Supports multi-host configuration

DOTFILES="$HOME/dotfiles"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[-]${NC} $1"; }
header() { echo -e "\n${BLUE}==>${NC} $1"; }

# Host selection
select_host() {
    echo ""
    echo "Select host profile:"
    echo "  1) personal-mac (default)"
    echo "  2) work-mac"
    echo "  3) linux-server"
    read -p "Choice [1]: " choice
    case "$choice" in
        2) echo "work-mac" ;;
        3) echo "linux-server" ;;
        *) echo "personal-mac" ;;
    esac
}

# Allow override via env var: HOST=work-mac ./install.sh
HOST="${HOST:-$(select_host)}"
echo ""
info "Using host profile: $HOST"

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

# Create .config if needed
mkdir -p "$HOME/.config"

# Zsh files
header "Setting up Zsh..."
backup_and_link "$DOTFILES/base/zsh/.zshrc" "$HOME/.zshrc"
backup_and_link "$DOTFILES/base/zsh/.zprofile" "$HOME/.zprofile"
backup_and_link "$DOTFILES/base/zsh/.zshenv" "$HOME/.zshenv"
backup_and_link "$DOTFILES/base/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

# Nushell
header "Setting up Nushell..."
# macOS uses ~/Library/Application Support/nushell, Linux uses ~/.config/nushell
if [[ "$OSTYPE" == "darwin"* ]]; then
    NU_CONFIG_DIR="$HOME/Library/Application Support/nushell"
else
    NU_CONFIG_DIR="$HOME/.config/nushell"
fi
mkdir -p "$NU_CONFIG_DIR"
backup_and_link "$DOTFILES/base/nushell/config.nu" "$NU_CONFIG_DIR/config.nu"
backup_and_link "$DOTFILES/base/nushell/env.nu" "$NU_CONFIG_DIR/env.nu"

# Generate Nushell tool integration scripts if nu is available
if command -v nu &> /dev/null; then
    info "Generating Nushell tool integrations..."
    mkdir -p "$DOTFILES/base/nushell/autoload"

    if command -v starship &> /dev/null; then
        nu -c 'starship init nu' > "$DOTFILES/base/nushell/autoload/starship.nu"
        info "Generated starship.nu"
    fi

    if command -v zoxide &> /dev/null; then
        nu -c 'zoxide init nushell' > "$DOTFILES/base/nushell/autoload/zoxide.nu"
        info "Generated zoxide.nu"
    fi

    if command -v atuin &> /dev/null; then
        nu -c 'atuin init nu --disable-up-arrow' > "$DOTFILES/base/nushell/autoload/atuin.nu"
        info "Generated atuin.nu"
    fi

    if command -v carapace &> /dev/null; then
        nu -c 'carapace _carapace nushell' > "$DOTFILES/base/nushell/autoload/carapace.nu"
        info "Generated carapace.nu"
    fi
fi

# Git
header "Setting up Git..."
backup_and_link "$DOTFILES/base/git/.gitconfig" "$HOME/.gitconfig"
mkdir -p "$HOME/.config/git"
backup_and_link "$DOTFILES/base/git/ignore" "$HOME/.config/git/ignore"

# Neovim
header "Setting up Neovim..."
backup_and_link "$DOTFILES/base/nvim" "$HOME/.config/nvim"

# Tmux
header "Setting up Tmux..."
mkdir -p "$HOME/.config/tmux"
backup_and_link "$DOTFILES/base/tmux/.tmux.conf" "$HOME/.config/tmux/.tmux.conf"

# Ghostty
header "Setting up Ghostty..."
mkdir -p "$HOME/.config/ghostty"
backup_and_link "$DOTFILES/base/ghostty/config" "$HOME/.config/ghostty/config"
backup_and_link "$DOTFILES/base/ghostty/themes" "$HOME/.config/ghostty/themes"

# Helix
header "Setting up Helix..."
backup_and_link "$DOTFILES/base/helix" "$HOME/.config/helix"

# Atuin
header "Setting up Atuin..."
mkdir -p "$HOME/.config/atuin"
backup_and_link "$DOTFILES/base/atuin/config.toml" "$HOME/.config/atuin/config.toml"

# Starship (just needs the config symlink for STARSHIP_CONFIG to work)
header "Setting up Starship..."
# Config is referenced via STARSHIP_CONFIG env var, no symlink needed

# Claude Code
header "Setting up Claude Code..."
mkdir -p "$HOME/.claude"
backup_and_link "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
backup_and_link "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
backup_and_link "$DOTFILES/claude/statusline.sh" "$HOME/.claude/statusline.sh"

# Readline / libedit
header "Setting up Readline..."
backup_and_link "$DOTFILES/base/readline/.inputrc" "$HOME/.inputrc"
backup_and_link "$DOTFILES/base/readline/.editrc" "$HOME/.editrc"

# Ripgrep
header "Setting up Ripgrep..."
backup_and_link "$DOTFILES/base/ripgrep/.ripgreprc" "$HOME/.ripgreprc"

# Bin scripts
header "Setting up bin scripts..."
mkdir -p "$HOME/bin"
backup_and_link "$DOTFILES/bin/tmux-sessionizer" "$HOME/bin/tmux-sessionizer"
chmod +x "$HOME/bin/tmux-sessionizer"

# Host-specific configuration
header "Setting up host-specific config ($HOST)..."
if [[ -d "$DOTFILES/hosts/$HOST" ]]; then
    info "Host profile found: $HOST"
    # Future: Link host-specific overrides here
else
    warn "No host-specific config found for: $HOST"
fi

echo ""
info "Done! Dotfiles installed for host: $HOST"
echo ""
warn "Next steps:"
echo "  1. Install packages:        brew bundle --file=$DOTFILES/Brewfile"
echo "  2. Configure macOS:         $DOTFILES/macos/defaults.sh"
echo "  3. Create local secrets:"
echo "     - Zsh:    cp $DOTFILES/base/zsh/.zshrc.local.example ~/.zshrc.local"
echo "     - Nushell: mkdir -p ~/.config/nushell/autoload && cp $DOTFILES/hosts/personal-mac/nushell/local.nu.example ~/.config/nushell/autoload/local.nu"
echo "  4. Set Nushell as default shell:"
echo "     - Add to /etc/shells:    sudo sh -c 'echo /opt/homebrew/bin/nu >> /etc/shells'"
echo "     - Change shell:          chsh -s /opt/homebrew/bin/nu"
echo "  5. Reload shell:            source ~/.zshrc (or start new terminal)"
