# dotfiles

Personal dotfiles with multi-host support. Nushell as default shell on personal Mac, zsh as fallback.

## Install

```bash
git clone https://github.com/papersson/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh  # Select host profile when prompted
```

## Structure

```
base/           # Shared configs (symlinked to ~)
├── nushell/    # Nu config + tool integrations
├── zsh/        # Zsh config (fallback)
├── nvim/       # Neovim
├── starship/   # Prompt
└── ...         # git, tmux, helix, ghostty, atuin, etc.

hosts/          # Machine-specific overrides
├── personal-mac/
├── work-mac/
└── linux-server/
```

## Post-install

**Set Nushell as default (optional):**
```bash
sudo sh -c 'echo /opt/homebrew/bin/nu >> /etc/shells'
chsh -s /opt/homebrew/bin/nu
```

**Local secrets:** Copy template to Nu's autoload directory:
```bash
cp hosts/personal-mac/nushell/local.nu.example \
   ~/Library/Application\ Support/nushell/autoload/local.nu
```

## Tools

Configured: starship, zoxide, atuin, carapace, eza, fzf, ripgrep, fd, bat, delta
