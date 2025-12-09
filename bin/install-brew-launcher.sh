#!/bin/zsh
#
# Install/uninstall the Homebrew update checker LaunchAgent
# This schedules weekly brew update checks to run at 9 AM on Mondays
#
# Usage: install-brew-launcher.sh [--uninstall]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PLIST_FILE="$PROJECT_ROOT/com.github.cajias.dotfiles.brew-update.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
INSTALLED_PLIST="$LAUNCH_AGENTS_DIR/com.github.cajias.dotfiles.brew-update.plist"
LABEL="com.github.cajias.dotfiles.brew-update"

# Function to install
install_launch_agent() {
  # Check if plist file exists
  if [[ ! -f "$PLIST_FILE" ]]; then
    echo "Error: LaunchAgent plist file not found at $PLIST_FILE"
    exit 1
  fi

  # Create LaunchAgents directory if it doesn't exist
  mkdir -p "$LAUNCH_AGENTS_DIR"

  # Copy plist to LaunchAgents directory
  echo "Installing LaunchAgent..."
  cp "$PLIST_FILE" "$INSTALLED_PLIST"
  chmod 644 "$INSTALLED_PLIST"

  # Load the LaunchAgent
  echo "Loading LaunchAgent with launchctl..."
  launchctl load "$INSTALLED_PLIST"

  echo "✓ Successfully installed Homebrew update checker"
  echo "  Will run every Monday at 9:00 AM"
  echo "  Log file: /var/tmp/com.github.cajias.dotfiles.brew-update.log"
  echo ""
  echo "To uninstall, run: install-brew-launcher.sh --uninstall"
}

# Function to uninstall
uninstall_launch_agent() {
  if [[ -f "$INSTALLED_PLIST" ]]; then
    echo "Unloading LaunchAgent..."
    launchctl unload "$INSTALLED_PLIST"

    echo "Removing LaunchAgent..."
    rm "$INSTALLED_PLIST"

    echo "✓ Successfully uninstalled Homebrew update checker"
  else
    echo "LaunchAgent not installed at $INSTALLED_PLIST"
    exit 1
  fi
}

# Parse arguments
if [[ "$1" == "--uninstall" ]]; then
  uninstall_launch_agent
else
  install_launch_agent
fi
