#!/usr/bin/env bash
# Installs the dotfiles in this repo on Linux.
#
# Symlinks the configs into place, copies machine-specific templates that don't exist yet
# and generates ~/.claude/settings.json. Existing files are moved aside to <name>.dotfiles-bak.
# Safe to run repeatedly.
#
# Usage: ./install.sh [--packages]
#   --packages  also install the tools these dotfiles use (apt-based distros)
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/scripts/dotfiles.sh"

install_packages() {
  if ! command -v apt-get >/dev/null; then
    echo "  apt-get not found; install zsh, git, neovim, jq, ripgrep and oh-my-posh yourself" >&2
    return
  fi
  sudo apt-get update
  sudo apt-get install -y zsh git neovim jq ripgrep curl unzip build-essential
  command -v oh-my-posh >/dev/null || curl -fsSL https://ohmyposh.dev/install.sh | bash -s
  command -v claude >/dev/null || curl -fsSL https://claude.ai/install.sh | bash
  [ "$(basename "${SHELL:-}")" = zsh ] || echo "  run 'chsh -s $(command -v zsh)' to make zsh your login shell"
}

move_to_backup() {
  local backup="$1$BACKUP_SUFFIX"
  if [ -e "$backup" ]; then backup="$1$BACKUP_SUFFIX-$(date +%Y%m%d%H%M%S)"; fi
  mv "$1" "$backup"
  echo "  backed up $1 -> $backup"
}

install_link() {
  local source="$REPO/$1" target=$2
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "  ok      $target"
    return
  fi
  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    move_to_backup "$target"
  fi
  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  echo "  linked  $target -> $source"
}

if [ "${1:-}" = "--packages" ]; then
  echo "Installing packages"
  install_packages
fi

echo "Linking dotfiles"
for link in "${LINKS[@]}"; do
  install_link "${link%%|*}" "${link#*|}"
done

echo "Machine-specific files"
for file in "${LOCAL_FILES[@]}"; do
  source_file="$REPO/${file%%|*}" target=${file#*|}
  if [ -e "$target" ]; then
    echo "  ok      $target"
  else
    mkdir -p "$(dirname "$target")"
    cp "$source_file" "$target"
    echo "  created $target"
  fi
done

echo "Claude Code settings"
settings=$(claude_settings)
if [ -f "$CLAUDE_SETTINGS" ] && [ "$(cat "$CLAUDE_SETTINGS")" = "$settings" ]; then
  echo "  ok      $CLAUDE_SETTINGS"
else
  if [ -e "$CLAUDE_SETTINGS" ]; then move_to_backup "$CLAUDE_SETTINGS"; fi
  mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
  printf '%s\n' "$settings" > "$CLAUDE_SETTINGS"
  echo "  wrote   $CLAUDE_SETTINGS"
fi

echo "Done."
