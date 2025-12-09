# ============================================================================
# Makefile for Shell Settings
# ============================================================================
# Description: Convenient commands for managing ZSH shell configuration
# Usage: make [target]
#        make help     - Show all available commands
# ============================================================================

# Configuration
SHELL := /bin/zsh
.DEFAULT_GOAL := help

# Project paths
PROJECT_ROOT := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BIN_DIR := $(PROJECT_ROOT)/bin
INIT_FILE := $(PROJECT_ROOT)/init.zsh
PLIST_FILE := $(PROJECT_ROOT)/com.github.cajias.dotfiles.brew-update.plist

# User paths
HOME_DIR := $(HOME)
SHELDON_CONFIG_DIR := $(HOME_DIR)/.config/sheldon
SHELDON_DATA_DIR := $(HOME_DIR)/.local/share/sheldon
SHELDON_PLUGINS_TOML := $(SHELDON_CONFIG_DIR)/plugins.toml
SHELDON_LOCK := $(SHELDON_DATA_DIR)/plugins.lock

# LaunchAgent configuration
LAUNCH_AGENTS_DIR := $(HOME_DIR)/Library/LaunchAgents
INSTALLED_PLIST := $(LAUNCH_AGENTS_DIR)/com.github.cajias.dotfiles.brew-update.plist
LAUNCH_LABEL := com.github.cajias.dotfiles.brew-update
LAUNCH_LOG := /var/tmp/com.github.cajias.dotfiles.brew-update.log
LAUNCH_ERR_LOG := /var/tmp/com.github.cajias.dotfiles.brew-update.err

# Colors
COLOR_RESET := \033[0m
COLOR_BOLD := \033[1m
COLOR_GREEN := \033[32m
COLOR_YELLOW := \033[33m
COLOR_CYAN := \033[36m
COLOR_RED := \033[31m

# ============================================================================
# PHONY Targets
# ============================================================================

.PHONY: help info paths setup install-sheldon install-launcher uninstall-launcher
.PHONY: reload update-plugins clear-completions refresh
.PHONY: check-launcher-status view-logs check-updates
.PHONY: validate test-config check-deps lint
.PHONY: _check-sheldon _check-init-zsh

# ============================================================================
# Helper Functions
# ============================================================================

_check-sheldon:
	@command -v sheldon >/dev/null 2>&1 || { \
		echo "$(COLOR_RED)Error: Sheldon not found$(COLOR_RESET)"; \
		echo "Install with: make install-sheldon"; \
		exit 1; \
	}

_check-init-zsh:
	@[ -f "$(INIT_FILE)" ] || { \
		echo "$(COLOR_RED)Error: init.zsh not found at $(INIT_FILE)$(COLOR_RESET)"; \
		exit 1; \
	}

# ============================================================================
# Information & Help
# ============================================================================

##@ Information & Help

help: ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\n$(COLOR_BOLD)Shell Settings - Available Commands$(COLOR_RESET)\n\n"} \
		/^[a-zA-Z_-]+:.*?##/ { printf "  $(COLOR_CYAN)%-22s$(COLOR_RESET) %s\n", $$1, $$2 } \
		/^##@/ { printf "\n$(COLOR_BOLD)%s$(COLOR_RESET)\n", substr($$0, 5) } ' \
		$(MAKEFILE_LIST)

info: ## Display configuration and status
	@echo "$(COLOR_BOLD)Shell Settings Configuration$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_CYAN)Project:$(COLOR_RESET)"
	@echo "  Root:              $(PROJECT_ROOT)"
	@echo "  Init script:       $(INIT_FILE)"
	@echo "  Bin directory:     $(BIN_DIR)"
	@echo ""
	@echo "$(COLOR_CYAN)Sheldon:$(COLOR_RESET)"
	@if command -v sheldon >/dev/null 2>&1; then \
		echo "  Status:            $(COLOR_GREEN)Installed$(COLOR_RESET)"; \
		echo "  Version:           $$(sheldon --version 2>/dev/null | head -1)"; \
		echo "  Config:            $(SHELDON_PLUGINS_TOML)"; \
		echo "  Data directory:    $(SHELDON_DATA_DIR)"; \
	else \
		echo "  Status:            $(COLOR_YELLOW)Not installed$(COLOR_RESET)"; \
	fi
	@echo ""
	@echo "$(COLOR_CYAN)LaunchAgent:$(COLOR_RESET)"
	@if launchctl list 2>/dev/null | grep -q "$(LAUNCH_LABEL)"; then \
		echo "  Status:            $(COLOR_GREEN)Loaded$(COLOR_RESET)"; \
		echo "  Plist:             $(INSTALLED_PLIST)"; \
		echo "  Log:               $(LAUNCH_LOG)"; \
		echo "  Schedule:          Every Monday at 9:00 AM"; \
	else \
		echo "  Status:            $(COLOR_YELLOW)Not loaded$(COLOR_RESET)"; \
		echo "  Install with:      make install-launcher"; \
	fi

paths: ## Show important directory paths
	@echo "$(COLOR_BOLD)Directory Paths$(COLOR_RESET)"
	@echo ""
	@echo "Project:"
	@echo "  $(PROJECT_ROOT)"
	@echo ""
	@echo "Sheldon:"
	@echo "  Config:   $(SHELDON_CONFIG_DIR)"
	@echo "  Data:     $(SHELDON_DATA_DIR)"
	@echo ""
	@echo "LaunchAgent:"
	@echo "  Installed: $(LAUNCH_AGENTS_DIR)"
	@echo "  Logs:      /var/tmp"

# ============================================================================
# Setup & Installation
# ============================================================================

##@ Setup & Installation

setup: ## First-time setup (install Sheldon + plugins + launcher)
	@echo "$(COLOR_BOLD)Setting up shell environment...$(COLOR_RESET)"
	@echo ""
	@$(MAKE) install-sheldon
	@echo ""
	@$(MAKE) update-plugins
	@echo ""
	@$(MAKE) install-launcher
	@echo ""
	@echo "$(COLOR_GREEN)✓ Setup complete!$(COLOR_RESET)"
	@echo ""
	@echo "To reload your shell, run one of:"
	@echo "  source $(INIT_FILE)"
	@echo "  exec zsh"

install-sheldon: ## Install Sheldon plugin manager via Homebrew
	@if command -v sheldon >/dev/null 2>&1; then \
		echo "$(COLOR_YELLOW)Sheldon already installed:$(COLOR_RESET)"; \
		sheldon --version; \
	else \
		echo "Installing Sheldon via Homebrew..."; \
		brew install sheldon && \
		echo "$(COLOR_GREEN)✓ Sheldon installed successfully$(COLOR_RESET)"; \
	fi

install-launcher: ## Install LaunchAgent for weekly brew updates
	@$(BIN_DIR)/install-brew-launcher.sh

uninstall-launcher: ## Uninstall the LaunchAgent
	@$(BIN_DIR)/install-brew-launcher.sh --uninstall

# ============================================================================
# Daily Development
# ============================================================================

##@ Daily Development

reload: _check-init-zsh ## Reload shell configuration
	@echo "$(COLOR_YELLOW)Note:$(COLOR_RESET) To reload your current shell, run:"
	@echo ""
	@echo "  source $(INIT_FILE)"
	@echo "  or"
	@echo "  exec zsh"
	@echo ""
	@echo "Testing in subshell:"
	@zsh -c "source $(INIT_FILE); echo '$(COLOR_GREEN)✓ Config loaded successfully$(COLOR_RESET)'"

update-plugins: _check-sheldon ## Update Sheldon plugins and regenerate lock file
	@echo "Updating Sheldon plugins..."
	@sheldon lock --update
	@echo "$(COLOR_GREEN)✓ Plugins updated successfully$(COLOR_RESET)"
	@echo ""
	@echo "Run 'make reload' to apply changes"

clear-completions: ## Clear ZSH completion cache
	@echo "Clearing completion cache..."
	@rm -f $(HOME_DIR)/.zcompdump*
	@echo "$(COLOR_GREEN)✓ Completion cache cleared$(COLOR_RESET)"
	@echo ""
	@echo "Run 'make reload' to rebuild the cache"

refresh: clear-completions update-plugins reload ## Clear cache, update plugins, reload shell

# ============================================================================
# Maintenance & Updates
# ============================================================================

##@ Maintenance & Updates

check-launcher-status: ## Show LaunchAgent status
	@echo "$(COLOR_BOLD)LaunchAgent Status$(COLOR_RESET)"
	@echo ""
	@if launchctl list 2>/dev/null | grep -q "$(LAUNCH_LABEL)"; then \
		echo "$(COLOR_GREEN)✓ LaunchAgent is loaded$(COLOR_RESET)"; \
		echo ""; \
		launchctl list | grep "$(LAUNCH_LABEL)"; \
	else \
		echo "$(COLOR_YELLOW)LaunchAgent is not loaded$(COLOR_RESET)"; \
		echo ""; \
		echo "Install with: make install-launcher"; \
	fi

view-logs: ## View LaunchAgent logs
	@if [ -f "$(LAUNCH_LOG)" ]; then \
		echo "$(COLOR_BOLD)LaunchAgent Log (last 30 lines)$(COLOR_RESET)"; \
		echo ""; \
		tail -30 $(LAUNCH_LOG); \
		echo ""; \
	else \
		echo "$(COLOR_YELLOW)No log file found at $(LAUNCH_LOG)$(COLOR_RESET)"; \
	fi
	@if [ -f "$(LAUNCH_ERR_LOG)" ]; then \
		echo ""; \
		echo "$(COLOR_BOLD)Error Log (last 30 lines)$(COLOR_RESET)"; \
		echo ""; \
		tail -30 $(LAUNCH_ERR_LOG); \
	fi

check-updates: ## Check for Homebrew updates manually
	@$(BIN_DIR)/update-brew-interactive.sh

# ============================================================================
# Validation & Testing
# ============================================================================

##@ Validation & Testing

validate: _check-init-zsh ## Validate shell configuration syntax
	@echo "Validating init.zsh syntax..."
	@if zsh -n $(INIT_FILE) 2>/dev/null; then \
		echo "$(COLOR_GREEN)✓ Syntax valid$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_RED)✗ Syntax error$(COLOR_RESET)"; \
		exit 1; \
	fi
	@echo ""
	@echo "Validating bin scripts..."
	@for script in $(BIN_DIR)/*.sh; do \
		name=$$(basename $$script); \
		if zsh -n $$script 2>/dev/null; then \
			echo "  $(COLOR_GREEN)✓$(COLOR_RESET) $$name"; \
		else \
			echo "  $(COLOR_RED)✗$(COLOR_RESET) $$name"; \
			exit 1; \
		fi; \
	done
	@echo ""
	@echo "$(COLOR_GREEN)✓ All validation passed$(COLOR_RESET)"

test-config: _check-init-zsh ## Test init.zsh in a subshell
	@echo "Testing init.zsh in subshell..."
	@echo ""
	@zsh -c "source $(INIT_FILE); echo '$(COLOR_GREEN)✓ Config loaded successfully in subshell$(COLOR_RESET)'"

check-deps: ## Check if all dependencies are installed
	@echo "$(COLOR_BOLD)Checking Dependencies$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_CYAN)Required:$(COLOR_RESET)"
	@echo -n "  ZSH:       "; \
		if command -v zsh >/dev/null 2>&1; then \
			echo "$(COLOR_GREEN)✓$(COLOR_RESET) $$(zsh --version | head -1)"; \
		else \
			echo "$(COLOR_RED)✗ Missing$(COLOR_RESET)"; \
		fi
	@echo -n "  Homebrew:  "; \
		if command -v brew >/dev/null 2>&1; then \
			echo "$(COLOR_GREEN)✓$(COLOR_RESET)"; \
		else \
			echo "$(COLOR_RED)✗ Missing$(COLOR_RESET)"; \
		fi
	@echo ""
	@echo "$(COLOR_CYAN)Shell Configuration:$(COLOR_RESET)"
	@echo -n "  Sheldon:   "; \
		if command -v sheldon >/dev/null 2>&1; then \
			echo "$(COLOR_GREEN)✓$(COLOR_RESET) $$(sheldon --version 2>/dev/null | head -1)"; \
		else \
			echo "$(COLOR_YELLOW)⚠ Not installed$(COLOR_RESET) - Run: make install-sheldon"; \
		fi
	@echo ""
	@echo "$(COLOR_CYAN)Optional Tools:$(COLOR_RESET)"
	@echo -n "  Ollama:    "; \
		if command -v ollama >/dev/null 2>&1; then \
			echo "$(COLOR_GREEN)✓$(COLOR_RESET) (for cq/q scripts)"; \
		else \
			echo "$(COLOR_YELLOW)✗$(COLOR_RESET) Not installed"; \
		fi
	@echo -n "  direnv:    "; \
		if command -v direnv >/dev/null 2>&1; then \
			echo "$(COLOR_GREEN)✓$(COLOR_RESET)"; \
		else \
			echo "$(COLOR_YELLOW)✗$(COLOR_RESET) Not installed"; \
		fi
	@echo -n "  shellcheck:"; \
		if command -v shellcheck >/dev/null 2>&1; then \
			echo "$(COLOR_GREEN)✓$(COLOR_RESET) (for lint)"; \
		else \
			echo "$(COLOR_YELLOW)✗$(COLOR_RESET) Not installed"; \
		fi

lint: ## Check shell scripts with shellcheck (if available)
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "Linting shell scripts..."; \
		echo ""; \
		shellcheck $(INIT_FILE) $(BIN_DIR)/*.sh || exit 1; \
		echo ""; \
		echo "$(COLOR_GREEN)✓ All scripts passed linting$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_YELLOW)shellcheck not installed$(COLOR_RESET)"; \
		echo "Install with: brew install shellcheck"; \
	fi
