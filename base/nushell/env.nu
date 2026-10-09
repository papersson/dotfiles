# env.nu - Nushell environment configuration

# PATH configuration (prepend order matters - last prepended has highest priority)
$env.PATH = (
    $env.PATH
    | split row (char esep)
    | prepend "/usr/local/bin"
    | prepend "/opt/homebrew/bin"
    | prepend "/opt/homebrew/sbin"
    | prepend "/opt/homebrew/opt/llvm/bin"
    | prepend "/opt/homebrew/opt/postgresql@17/bin"
    | prepend ($env.HOME | path join ".local/bin")
    | prepend ($env.HOME | path join ".bun/bin")
    | prepend ($env.HOME | path join "Library/pnpm")
    | prepend ($env.HOME | path join "Library/Application Support/Coursier/bin")
    | prepend ($env.HOME | path join ".cargo/bin")
    | prepend ($env.HOME | path join ".opencode/bin")
    | prepend ($env.HOME | path join ".bend/bin")
    | prepend "/nix/var/nix/profiles/default/bin"
    | prepend ($env.HOME | path join ".nix-profile/bin")
    | uniq
)

# Editor
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# Tool configs
$env.RIPGREP_CONFIG_PATH = ($env.HOME | path join ".ripgreprc")
$env.STARSHIP_CONFIG = ($env.HOME | path join "dotfiles/base/starship/starship.toml")
$env.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense"

# Starship prompt setup
$env.STARSHIP_SHELL = "nu"

# Local environment (secrets, machine-specific)
# Create ~/.config/nushell/local.nu for API keys, work-specific settings, etc.
# Note: Nushell's autoload directories (~/.config/nushell/autoload/) are also sourced
# You can place local.nu there instead for automatic loading
