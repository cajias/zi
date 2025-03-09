########################################################
# 
# My z-shell preferences
#
setopt prompt_subst
export ZSH_COLORIZE_TOOL=chroma
export NVM_COMPLETION=true
export NVM_SYMLINK_CURRENT="true"

# Install Sheldon plugin manager if not already installed
SHELDON_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon"
if [[ ! -f "$SHELDON_DIR/repos.lock" ]]; then
  echo "Installing Sheldon plugin manager..."
  if command -v brew >/dev/null 2>&1; then
    brew install sheldon
  else
    echo "Please install Sheldon using your package manager or cargo:"
    echo "  cargo install sheldon"
    # Create temporary directory structure
    mkdir -p "$SHELDON_DIR"
  fi
fi

# Initialize Sheldon
if command -v sheldon >/dev/null 2>&1; then
  # Create sheldon config if it doesn't exist
  SHELDON_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/sheldon"
  mkdir -p "$SHELDON_CONFIG_DIR"
  
  if [[ ! -f "$SHELDON_CONFIG_DIR/plugins.toml" ]]; then
    cat > "$SHELDON_CONFIG_DIR/plugins.toml" << 'EOF'
# Sheldon configuration file

shell = "zsh"

[plugins]

[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"

[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"

[plugins.zsh-completions]
github = "zsh-users/zsh-completions"

[plugins.powerlevel10k]
github = "romkatv/powerlevel10k"

[plugins.fast-syntax-highlighting]
github = "zdharma-continuum/fast-syntax-highlighting"

[plugins.zsh-history-substring-search]
github = "zsh-users/zsh-history-substring-search"

[plugins.fzf-tab]
github = "Aloxaf/fzf-tab"

[plugins.zsh-nvm]
github = "lukechilds/zsh-nvm"

[plugins.ohmyzsh-lib]
github = "ohmyzsh/ohmyzsh"
dir = "lib"

[plugins.ohmyzsh-git]
github = "ohmyzsh/ohmyzsh"
dir = "plugins/git"

[plugins.ohmyzsh-ssh-agent]
github = "ohmyzsh/ohmyzsh"
dir = "plugins/ssh-agent"
use = ["ssh-agent.plugin.zsh"]
EOF
  fi
  
  # Source sheldon
  eval "$(sheldon source)"
else
  # Fallback to basic zsh configuration
  autoload -Uz compinit
  compinit
  
  # Pretty Completions
  zstyle ':completion:*' completer _complete _match _approximate
  zstyle ':completion:*:match:*' original only
  zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'
  zstyle ':completion:*:matches' group 'yes'
  zstyle ':completion:*:options' description 'yes'
  zstyle ':completion:*:options' auto-description '%d'
  zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
  zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
  zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
  zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
  zstyle ':completion:*:default' list-prompt '%S%M matches%s'
  zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
  zstyle ':completion:*' group-name ''
  zstyle ':completion:*' verbose yes
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
  zstyle ':completion:*' use-cache true
  zstyle ':completion:*' rehash true
fi

# Run brew update check using a terminal multiplexer or in a new window
brew_check_function() {
  # Only show brew updates if we're in an interactive shell
  if [[ -o interactive ]]; then
    # Wait for shell to finish loading
    sleep 3
    # If tmux is available, run in a new pane
    if command -v tmux &> /dev/null && [ -n "$TMUX" ]; then
      tmux new-window -n "Brew Updates" "$HOME/Projects/workspace/home/bin/update-brew-interactive.sh"
    # If iTerm2 is available, run in a new tab
    elif [ "$TERM_PROGRAM" = "iTerm.app" ]; then
      osascript -e 'tell application "iTerm2" to create window with default profile command "$HOME/Projects/workspace/home/bin/update-brew-interactive.sh"' &> /dev/null
    # Otherwise silently check and only show if updates are available
    else
      output=$(mktemp)
      # Run the update check silently
      nohup "$HOME/Projects/workspace/home/bin/update-brew-interactive.sh" > "$output" 2>&1 &
    fi
  fi
}

# Run the function in the background
brew_check_function &

# Load Powerlevel10k theme if available
if [[ -f "$HOME/.p10k.zsh" ]]; then
  source "$HOME/.p10k.zsh"
fi

# SSH agent configuration
# This will be handled by the ssh-agent plugin loaded by Sheldon
# If Sheldon isn't available, use manual setup
if ! command -v sheldon >/dev/null 2>&1; then
  ssh_agent_file="$HOME/.ssh/agent.env"

  function start_agent {
      echo "Initialising new SSH agent..."
      /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${ssh_agent_file}"
      echo succeeded
      chmod 600 "${ssh_agent_file}"
      . "${ssh_agent_file}" > /dev/null
      ssh-add --apple-load-keychain
  }

  # Source SSH settings, if applicable
  if [ -f "${ssh_agent_file}" ]; then
      . "${ssh_agent_file}" > /dev/null
      ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
          start_agent;
      }
  else
      start_agent;
  fi
else
  # Configure SSH agent when using Sheldon
  zstyle :omz:plugins:ssh-agent agent-forwarding yes
  zstyle :omz:plugins:ssh-agent lazy yes
  zstyle :omz:plugins:ssh-agent quiet yes
  zstyle :omz:plugins:ssh-agent ssh-add-args --apple-load-keychain
fi

# Configure NVM
# When using sheldon with zsh-nvm plugin, we don't need to manually source NVM
if ! command -v sheldon >/dev/null 2>&1; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load NVM
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Load NVM bash completion
else
  # These settings are used by the zsh-nvm plugin
  export NVM_COMPLETION=true
  export NVM_LAZY_LOAD=true
  export NVM_AUTO_USE=true
fi

# Add direnv support to Sheldon configuration if it's installed
if command -v direnv &> /dev/null && command -v sheldon >/dev/null 2>&1; then
  SHELDON_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/sheldon"
  if [[ -f "$SHELDON_CONFIG_DIR/plugins.toml" ]]; then
    # Check if direnv is already in the config
    if ! grep -q "\[plugins.direnv\]" "$SHELDON_CONFIG_DIR/plugins.toml"; then
      cat >> "$SHELDON_CONFIG_DIR/plugins.toml" << 'EOF'

[plugins.direnv]
inline = '''
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi
'''
EOF
    fi
  fi
fi

# Configure direnv if available (fallback if Sheldon isn't available)
if command -v direnv &> /dev/null && ! command -v sheldon >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Useful aliases
alias ls='ls -G'
alias ll='ls -lh'
alias la='ls -lah'
alias ..='cd ..'
alias ...='cd ../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gl='git log --oneline --graph'
alias gp='git push'
alias gpu='git pull'

# Note: We've switched from zi to Sheldon, a Rust-based plugin manager
# Sheldon is faster, more reliable, and uses TOML for configuration
# To learn more or customize further: https://sheldon.cli.rs/