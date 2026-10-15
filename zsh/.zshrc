# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd extendedglob nomatch notify
bindkey -v
bindkey '^R' history-incremental-search-backward
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

alias v="nvim"
alias py="python3"
alias ll="ls -al"
alias llg="ls -al | grep "
alias c="clear"
alias gpi="getpublic_ip"
alias xfcd="xfce4-terminal $CD --hide-menubar --hide-scrollbar"

test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# User-level installs from devtools.sh
test -d ~/.dotnet && export DOTNET_ROOT=~/.dotnet && path=(~/.dotnet ~/.dotnet/tools $path)
test -d ~/.cargo/bin && path=(~/.cargo/bin $path)
test -d ~/.aspire/bin && path=(~/.aspire/bin $path)
path=(~/.local/bin $path)

command -v oh-my-posh >/dev/null && eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/theme.omp.json)"

# Machine-specific settings (not in the dotfiles repo)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
