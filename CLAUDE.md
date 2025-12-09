# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains personal shell configuration and utility scripts for a macOS development environment. It provides a modern, opinionated ZSH setup with plugin management, development tools, and interactive utilities.

## Architecture & Key Components

### Shell Configuration System
The core of this project is `init.zsh`, which initializes the ZSH environment and manages plugins through **Sheldon** (a plugin manager). Key features:

- **Plugin Manager**: Sheldon handles installation and initialization of ZSH plugins
- **Automatic Setup**: If Sheldon is not installed, the script provides installation instructions
- **Configuration**: Plugin list is stored in `~/.config/sheldon/plugins.toml`
- **Fallback**: If Sheldon is unavailable, the script falls back to basic ZSH configuration with manual completion setup

### Plugin Stack
The Sheldon configuration (`~/.config/sheldon/plugins.toml`) includes:
- **Autosuggestions**: `zsh-autosuggestions` - inline command suggestions
- **Completions**: `zsh-completions` - extended completion definitions
- **Syntax Highlighting**: `fast-syntax-highlighting` - fast, feature-rich syntax highlighting
- **History Search**: `zsh-history-substring-search` - search history by substring
- **Prompt**: `powerlevel10k` - rich, customizable terminal prompt
- **Version Management**: `zsh-nvm` - Node.js version switching
- **SSH Agent**: OH MY ZSH ssh-agent plugin - macOS Keychain integration
- **Git Integration**: OH MY ZSH git plugin - Git aliases and utilities

### Utility Scripts
Scripts in the `bin/` directory are organized by function:

| Script | Purpose |
|--------|---------|
| `install-brew-launcher.sh` | Install/uninstall the macOS LaunchAgent for weekly brew updates |
| `update-brew-interactive.sh` | Interactive Homebrew update checker (called by LaunchAgent) |
| `git-user-stats` | Git analytics - shows commit counts, files modified, and line changes per author |
| `cq` | Quick code query - runs CodeLlama 13B locally via Ollama |
| `q` | Quick general query - runs Llama2-uncensored locally via Ollama |
| `qc` | Utility stub (minimal implementation) |
| `webstorm` | Opens WebStorm IDE from command line |

### Homebrew Update Checker
The project includes a macOS LaunchAgent that checks for Homebrew updates every Monday at 9:00 AM:

**Installation:**
```bash
$HOME/Projects/workspace/home/bin/install-brew-launcher.sh
```

**Uninstallation:**
```bash
$HOME/Projects/workspace/home/bin/install-brew-launcher.sh --uninstall
```

The LaunchAgent (`com.github.cajias.dotfiles.brew-update.plist`) runs the `update-brew-interactive.sh` script weekly. If updates are available, it opens an interactive iTerm window (or runs in the current terminal) where you can choose to upgrade.

### Installation & Distribution
The project is distributed via Homebrew:
- **Tap**: `cajias/homebrew-tools`
- **Formula**: `shell-settings`
- **Distribution Method**: GitHub releases with automated formula updates

### GitHub Actions Integration
**Workflow**: `.github/workflows/update-homebrew-tap.yml`

Triggers automatically on push to main (changes to `init.zsh` or `bin/**`). Workflow:
1. Creates dated version tag: `v{YYYYMMDD}.{COMMIT_HASH}`
2. Creates GitHub Release with the tag
3. Calculates SHA256 of release tarball
4. Updates the Homebrew formula in `cajias/homebrew-tools` repository
5. Commits and pushes formula changes

**Requirements**: `TAP_REPO_TOKEN` secret must be set in repository settings (personal access token with repo scope for homebrew-tools)

### iTerm2 Configuration
`iterm/Default.json` contains iTerm2 profile settings. This is a binary JSON export of terminal preferences and should not be manually edited. Update through iTerm2 UI and export if changes are needed.

## Command Manager (Makefile)

A `Makefile` provides convenient shortcuts for common operations without needing to remember script names or paths.

### Quick Start
```bash
make help          # Show all available commands
make info          # Display current configuration and status
make setup         # First-time setup (install Sheldon + plugins + launcher)
make reload        # Reload shell configuration
make check-deps    # Check all dependencies
```

### Command Categories

**Information & Help:**
- `make help` - Show all available commands with descriptions
- `make info` - Display configuration paths, versions, LaunchAgent status
- `make paths` - Show important directory paths
- `make check-deps` - Verify all required/optional dependencies

**Setup & Installation:**
- `make setup` - Complete first-time setup (Sheldon + plugins + LaunchAgent)
- `make install-sheldon` - Install Sheldon plugin manager via Homebrew
- `make install-launcher` - Install the LaunchAgent for weekly brew updates
- `make uninstall-launcher` - Uninstall the LaunchAgent

**Daily Development:**
- `make reload` - Reload shell configuration
- `make update-plugins` - Update Sheldon plugins with `sheldon lock --update`
- `make clear-completions` - Clear ZSH completion cache (`~/.zcompdump*`)
- `make refresh` - Combo: clear completions + update plugins + reload

**Maintenance & Updates:**
- `make check-launcher-status` - Show LaunchAgent status
- `make view-logs` - Display LaunchAgent logs
- `make check-updates` - Manually check for Homebrew updates

**Validation & Testing:**
- `make validate` - Validate shell script syntax (init.zsh + bin scripts)
- `make test-config` - Test init.zsh in a subshell
- `make lint` - Check shell scripts with shellcheck (if installed)

## Common Development Tasks

### Adding a New Shell Alias or Function
1. Modify `init.zsh` directly or create a plugin configuration in Sheldon's `plugins.toml`
2. Test the changes by sourcing the file: `source init.zsh`
3. Push to main - GitHub Actions will automatically create a release and update the Homebrew formula

### Adding a New Utility Script
1. Create executable script in `bin/` directory
2. Ensure it has a proper shebang (e.g., `#!/bin/zsh` or `#!/bin/bash`)
3. Make it executable: `chmod +x bin/your-script`
4. Push to main - GitHub Actions will automatically update the Homebrew formula

### Testing Shell Configuration Changes
```bash
# Source the configuration in a new ZSH session
zsh -c "source /path/to/init.zsh; <your-test-command>"

# Or reload in current session
source init.zsh
```

### Updating Sheldon Plugins
1. Edit `~/.config/sheldon/plugins.toml` to add/remove plugins
2. Regenerate Sheldon lock file: `sheldon lock --update`
3. Reload shell: `exec zsh`

**Note**: Do not use `fzf-tab` unless `fzf` is installed. It requires the `fzf` command-line tool to function properly.

### Testing Homebrew Formula Locally
After GitHub Actions creates a release, test installation:
```bash
brew install cajias/homebrew-tools/shell-settings
```

Or update an existing installation:
```bash
brew upgrade cajias/homebrew-tools/shell-settings
```

## Environment Variables & Configuration

### Sheldon Directories
- **Data**: `${XDG_DATA_HOME:-$HOME/.local/share}/sheldon` (lock files, cached plugins)
- **Config**: `${XDG_CONFIG_HOME:-$HOME/.config}/sheldon` (plugins.toml configuration)

### ZSH Options
Key options set in `init.zsh`:
- `prompt_subst`: Enable prompt substitution
- `NVM_COMPLETION`: Enable Node.js version manager completions
- `NVM_SYMLINK_CURRENT`: Symlink `current` directory for nvm

### Homebrew Integration
- Weekly update check runs automatically via `update-brew-interactive.sh`
- Timestamp stored in `bin/.daily_script_timestamp` (unix week number)
- User is prompted interactively to update if packages are available

## Maintenance & Release Process

### Automatic Release Cycle
1. Make changes to `init.zsh` or files in `bin/`
2. Commit and push to `main`
3. GitHub Actions workflow triggers automatically
4. Creates release tag, GitHub release, updates Homebrew formula
5. Users can `brew upgrade` to get latest version

### Manual Trigger
The GitHub Actions workflow can be triggered manually via GitHub UI under "Run workflow"

### Version Scheme
Versions follow format: `{YYYYMMDD}.{SHORT_COMMIT_HASH}`
- Example: `20250312.a1b2c3d`

### Breaking Changes
If breaking changes are introduced to shell configuration:
1. Document in GitHub release notes
2. Consider adding upgrade instructions in init.zsh
3. Sheldon lock files may need to be regenerated by users

## Local Tools & Dependencies

### Required Tools
- **ZSH**: Shell interpreter (macOS ships with ZSH)
- **Sheldon**: Plugin manager - install via `brew install sheldon` or `cargo install sheldon`
- **Git**: Version control
- **Homebrew**: Package manager (for distribution and updates)

### Optional Tools
- **Ollama**: Required for `cq` and `q` scripts - install via `brew install ollama`
- **WebStorm**: IDE - required for `webstorm` script
- **NVM**: Node.js version manager - auto-installed via zsh-nvm plugin

### External Services
- GitHub API: Used by `git-quick-stats` symlink (points to external repository)

## Troubleshooting

### Autocomplete Not Working
If tab completion stops working after updating plugins:
```bash
rm -f ~/.zcompdump*
sheldon lock --update
exec zsh
```

This clears the completion cache and rebuilds it with the current plugins.

### Conflicts to Avoid
- Do not load both `zsh-syntax-highlighting` and `fast-syntax-highlighting` - they conflict. Use only `fast-syntax-highlighting` for better performance.
- Do not enable `fzf-tab` unless `fzf` is installed - it will break the default completion menu.

## Important Notes

- The project uses modern ZSH plugin management via Sheldon (not Oh My ZSH as primary manager, though some plugins are sourced from OMZ)
- All shell scripts should remain POSIX-compatible where possible for portability
- The Homebrew automation requires a GitHub personal access token - document this clearly for anyone setting up the tap
- iTerm2 configuration is environment-specific and should be updated through the UI, not manually edited in JSON
- The `bin/` directory is installed system-wide when distributed via Homebrew, so scripts should have clear usage documentation
