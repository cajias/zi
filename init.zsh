########################################################
# 
# My z-shell preferences
#

export ZSH_COLORIZE_TOOL=chroma
export NVM_COMPLETION=true
export NVM_SYMLINK_CURRENT="true"
export ZSH_THEME="robbyrussell"

zinit ice blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

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

autoload compinit
compinit

zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit snippet OMZP::git-prompt



zinit as"program" make'!' atclone'./direnv hook zsh > zhook.zsh' \
    atpull'%atclone' pick"direnv" src"zhook.zsh" for \
        direnv/direnv

zinit wait lucid light-mode for \
      OMZP::colored-man-pages \
      OMZP::dotenv \
      OMZP::timer \
      OMZP::colorize \
      z-shell/H-S-MW \
      z-shell/F-Sy-H \
      lukechilds/zsh-nvm

zinit snippet OMZL::git.zsh

zinit snippet OMZP::git
zinit snippet OMZL::theme-and-appearance.zsh
zinit snippet OMZL::prompt_info_functions.zsh
setopt prompt_subst
zinit snippet OMZT::robbyrussell


zinit snippet OMZP::ssh-agent
zstyle :omz:plugins:ssh-agent lazy yes
zstyle :omz:plugins:ssh-agent helper ksshaskpass

zinit snippet OMZL::directories.zsh
zinit snippet OMZL::history.zsh
