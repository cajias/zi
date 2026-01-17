#!/bin/zsh
#
# Install/uninstall the Homebrew update checker LaunchAgent
# This schedules weekly brew update checks to run at 9 AM on Mondays
#
# Usage: install-brew-launcher.sh [--uninstall]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
INSTALLED_PLIST="$LAUNCH_AGENTS_DIR/com.github.cajias.dotfiles.brew-update.plist"
LABEL="com.github.cajias.dotfiles.brew-update"
UPDATE_SCRIPT="$SCRIPT_DIR/update-brew-interactive.sh"

# Function to generate plist content with correct paths
generate_plist() {
  cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/zsh</string>
        <string>-c</string>
        <string>
if [ "\$TERM_PROGRAM" = "iTerm.app" ] || [ -z "\$TERM_PROGRAM" ]; then
  osascript -e 'tell application "iTerm" to create window with default profile command "$UPDATE_SCRIPT"' 2>/dev/null
else
  $UPDATE_SCRIPT
fi
        </string>
    </array>
    <key>StartCalendarInterval</key>
    <array>
        <dict>
            <key>Day</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>9</integer>
            <key>Minute</key>
            <integer>0</integer>
            <key>Weekday</key>
            <integer>1</integer>
        </dict>
    </array>
    <key>StandardOutPath</key>
    <string>/var/tmp/com.github.cajias.dotfiles.brew-update.log</string>
    <key>StandardErrorPath</key>
    <string>/var/tmp/com.github.cajias.dotfiles.brew-update.err</string>
</dict>
</plist>
EOF
}

# Function to install
install_launch_agent() {
  # Check if update script exists
  if [[ ! -f "$UPDATE_SCRIPT" ]]; then
    echo "Error: Update script not found at $UPDATE_SCRIPT"
    exit 1
  fi

  # Create LaunchAgents directory if it doesn't exist
  mkdir -p "$LAUNCH_AGENTS_DIR"

  # Generate and install plist
  echo "Installing LaunchAgent..."
  generate_plist > "$INSTALLED_PLIST"
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
