########################################################
# 
# My z-shell preferences
#

zinit snippet OMZP::git-prompt

zinit wait lucid for \
  atinit"zicompinit; zicdreplay"  \
        zdharma-continuum/fast-syntax-highlighting \
      OMZP::colored-man-pages \
      OMZP::dotenv \
      OMZP::timer \
      OMZP::ssh-agent \
      OMZP::colorize \
      z-shell/H-S-MW \
      z-shell/F-Sy-H

ZSH_COLORIZE_TOOL=chroma

zinit as"program" make'!' atclone'./direnv hook zsh > zhook.zsh' \
    atpull'%atclone' pick"direnv" src"zhook.zsh" for \
        direnv/direnv

zinit snippet OMZL::git.zsh

zinit snippet OMZP::git
zinit snippet OMZL::theme-and-appearance.zsh
zinit snippet OMZL::prompt_info_functions.zsh
setopt prompt_subst
zinit snippet OMZT::robbyrussell
ZSH_THEME="robbyrussell"

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



zstyle :omz:plugins:ssh-agent identities ~/.ssh/id_ecdsa.pub
zstyle :omz:plugins:ssh-agent lazy yes
zstyle :omz:plugins:ssh-agent helper ksshaskpass


export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

zinit snippet OMZL::nvm.zsh

zinit snippet OMZL::directories.zsh
zinit snippet OMZL::history.zsh
