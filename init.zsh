########################################################
#
# My z-shell preferences
#
setopt prompt_subst
export ZSH_COLORIZE_TOOL=chroma
export NVM_SYMLINK_CURRENT="true"

# Check if Sheldon plugin manager is installed
SHELDON_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon"
if [[ ! -f "$SHELDON_DIR/repos.lock" ]] && ! command -v sheldon >/dev/null 2>&1; then
  # Create temporary directory structure
  mkdir -p "$SHELDON_DIR"
  # Only show message in interactive non-login shells if needed
  if [[ -o interactive ]]; then
    echo "Sheldon plugin manager not found. Please install it:"
    echo "  brew install sheldon"
    echo "  or"
    echo "  cargo install sheldon"
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
# For more plugins and configurations, see: https://github.com/rossmacarthur/sheldon

shell = "zsh"

[plugins]

# Performance: Async operations (required by some plugins)
[plugins.zsh-async]
github = "mafredri/zsh-async"

# Performance: Lazy load heavy plugins to speed up startup
# Example: lazyload fzf-tab zoxide npm -- eval "$(fzf-tab --init)"
[plugins.zsh-lazy-load]
github = "unixorn/zsh-lazyload"

# Autosuggestions
[plugins.zsh-autosuggestions]
github = "zsh-users/zsh-autosuggestions"

# Completions
[plugins.zsh-completions]
github = "zsh-users/zsh-completions"

# Syntax highlighting
[plugins.fast-syntax-highlighting]
github = "zdharma-continuum/fast-syntax-highlighting"

# History substring search
[plugins.zsh-history-substring-search]
github = "zsh-users/zsh-history-substring-search"

# Theme
[plugins.powerlevel10k]
github = "romkatv/powerlevel10k"

# Optional: Node.js NVM (lazy load with: lazyload nvm -- eval "$(nvm env --shell zsh)")
# [plugins.zsh-nvm]
# github = "lukechilds/zsh-nvm"

# Optional: Git shortcuts from Oh My Zsh
# [plugins.ohmyzsh-git]
# github = "ohmyzsh/ohmyzsh"
# dir = "plugins/git"

# Optional: SSH agent from Oh My Zsh
# [plugins.ohmyzsh-ssh-agent]
# github = "ohmyzsh/ohmyzsh"
# dir = "plugins/ssh-agent"
# use = ["ssh-agent.plugin.zsh"]
EOF
  fi

  # Source sheldon with output suppressed to avoid test messages
  eval "$(sheldon source 2>/dev/null)"

  # Explicitly initialize completions after plugins are loaded
  autoload -Uz compinit
  compinit
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
