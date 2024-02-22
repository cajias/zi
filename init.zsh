########################################################
# 
# My z-shell preferences
#
setopt prompt_subst
export ZSH_COLORIZE_TOOL=chroma
export NVM_COMPLETION=true
export NVM_SYMLINK_CURRENT="true"

autoload compinit
compinit


zi ice blockf atpull'zinit creinstall -q .'
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


zi as"program" make'!' atclone'./direnv hook zsh > zhook.zsh' \
    atpull'%atclone' pick"direnv" src"zhook.zsh" for \
        direnv/direnv

zi wait lucid light-mode for \
    zdharma-continuum/fast-syntax-highlighting \
    z-shell/H-S-MW \
    z-shell/F-Sy-H \
    lukechilds/zsh-nvm

zi snippet OMZP::ssh-agent
zstyle :omz:plugins:ssh-agent lazy yes
zstyle :omz:plugins:ssh-agent quiet yes
zstyle :omz:plugins:ssh-agent helper ksshaskpass
zstyle :omz:plugins:ssh-agent ssh-add-args --apple-load-keychain

zi ice depth=1; 
zi light romkatv/powerlevel10k
