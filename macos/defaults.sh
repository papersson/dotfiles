#!/usr/bin/env bash
set -euo pipefail

# macOS defaults
# Run manually: ./macos/defaults.sh
# Some changes require logout/restart to take effect

echo "Configuring macOS defaults..."

# ==============================================================================
# General UI/UX
# ==============================================================================
# Save to disk (not iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# ==============================================================================
# Keyboard
# ==============================================================================
# Fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for keys (enable key repeat)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# ==============================================================================
# Text Input (disable auto-everything for developers)
# ==============================================================================
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# ==============================================================================
# Trackpad / Mouse
# ==============================================================================
# Disable natural scrolling (scroll down = content moves down)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# ==============================================================================
# Security
# ==============================================================================
# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# ==============================================================================
# Finder
# ==============================================================================
# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar at bottom
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Use list view by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# New Finder windows show home directory
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Show ~/Library folder
chflags nohidden ~/Library

# ==============================================================================
# Dock
# ==============================================================================
# Auto-hide dock
defaults write com.apple.dock autohide -bool true

# Fast auto-hide animation
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3

# Don't show recent apps in dock
defaults write com.apple.dock show-recents -bool false

# Minimize windows to application icon
defaults write com.apple.dock minimize-to-application -bool true

# ==============================================================================
# Screenshots
# ==============================================================================
# Save screenshots to ~/Screenshots
mkdir -p "${HOME}/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

# Save as PNG
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# ==============================================================================
# Activity Monitor
# ==============================================================================
# Show all processes
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# ==============================================================================
# Apply changes
# ==============================================================================
echo "Restarting affected applications..."
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo ""
echo "Done! Some changes require logout/restart to take effect."
echo "Especially: keyboard repeat rate, scroll direction, password on wake"
