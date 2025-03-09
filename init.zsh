########################################################
# 
# My z-shell preferences
#
setopt prompt_subst
export ZSH_COLORIZE_TOOL=chroma
export NVM_COMPLETION=true
export NVM_SYMLINK_CURRENT="true"

# Load zi if you don't have it
if [[ ! -f $HOME/.zi/bin/zi.zsh ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "$HOME/.zi" && command chmod g-rwX "$HOME/.zi"
  command git clone -q --depth=1 --branch "main" https://github.com/z-shell/zi "$HOME/.zi/bin" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi
source "$HOME/.zi/bin/zi.zsh"
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi

# Use modern annex plugins
zi light-mode for \
  z-shell/z-a-meta-plugins \
  @annexes

# Completions
zi ice blockf atpull'zi creinstall -q .'
zi light zsh-users/zsh-completions
zi light zsh-users/zsh-autosuggestions

zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

# Pretty Completions
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

# Programs - with turbo mode for faster startup
zi as"program" make'!' atclone'./direnv hook zsh > zhook.zsh' \
    atpull'%atclone' pick"direnv" src"zhook.zsh" for \
        direnv/direnv

# Use modern z-shell packages with turbo mode
zi wait"0" lucid for \
    z-shell/F-Sy-H \
    z-shell/H-S-MW \
    atload"zicompinit; zicdreplay" \
    z-shell/fast-syntax-highlighting

# NVM with turbo mode
zi wait"1" lucid for \
    lukechilds/zsh-nvm

# SSH agent
zi snippet OMZP::ssh-agent
zstyle :omz:plugins:ssh-agent lazy yes
zstyle :omz:plugins:ssh-agent quiet yes
zstyle :omz:plugins:ssh-agent helper ksshaskpass
zstyle :omz:plugins:ssh-agent ssh-add-args --apple-load-keychain

# Theme
zi ice depth=1 lucid
zi light romkatv/powerlevel10k

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