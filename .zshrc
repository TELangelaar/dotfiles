# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd extendedglob nomatch notify
bindkey -v
bindkey '^R' history-incremental-search-backward
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/thijme/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

alias ll="ls -al"
alias llg="ls -al | grep "
alias matlab2015="/opt/MATLAB/R2015a/bin/matlab"
alias v="vim"
alias c="clear"
alias gpi="getpublic_ip"
alias xfcd="xfce4-terminal $CD --hide-menubar --hide-scrollbar"

test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"


eval "$(oh-my-posh --init --shell zsh --config /mnt/c/Users/Desktop-TL/AppData/Local/oh-my-posh/themes/jandedobbeleer.omp.json)"
