# Personal Shell Configuration

This repository contains my personal shell configuration settings and scripts.

## Features

- ZSH configuration using Sheldon plugin manager
- Syntax highlighting and auto-suggestions
- Git integration and useful aliases
- SSH agent with Apple keychain integration
- Node.js version management with NVM
- Project environment management with direnv
- Homebrew update checker

## Terminal Configuration

- Modern ZSH setup with completion
- Custom aliases for improved productivity
- Consistent styling and prompt with Powerlevel10k

## Git Integration

- Git aliases and shortcuts
- Improved Git command output

## Scripts

Helper scripts are available in the `bin` directory:
- Update Homebrew interactively
- Git utilities
- And more

## Installation

### Using Homebrew (recommended)

```bash
# Tap the repository
brew tap cajias/homebrew-tools

# Install the shell settings
brew install cajias/homebrew-tools/shell-settings

# Follow the instructions printed after installation
```

### Manual Installation

Clone this repository and source the initialization script in your `.zshrc`:

```bash
git clone https://github.com/cajias/zi.git ~/.shell-settings
echo 'source ~/.shell-settings/init.zsh' >> ~/.zshrc
```

## Automatic Updates

This repository is configured with GitHub Actions to automatically update the Homebrew formula when changes are pushed to the main branch.

### Setting up GitHub Actions

To set up the automatic updates workflow:

1. Go to your GitHub repository settings
2. Navigate to "Secrets and variables" > "Actions"
3. Create a new repository secret:
   - Name: `TAP_REPO_TOKEN`
   - Value: A GitHub personal access token with `repo` scope that has write access to your homebrew-tools repository

This token allows the GitHub Actions workflow to push updates to your Homebrew tap repository.