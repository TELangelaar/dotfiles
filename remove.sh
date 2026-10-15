#!/usr/bin/env bash
# Removes the dotfiles installed by install.sh.
#
# Deletes every symlink that points into this repo and the generated ~/.claude/settings.json,
# then restores the <name>.dotfiles-bak backups made by install.sh, if there are any.
# Machine-specific files (~/.zshrc.local, ~/.gitconfig.local, settings.local.json) are kept
# unless --include-local is passed.
#
# Usage: ./remove.sh [--include-local]
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/scripts/dotfiles.sh"

restore_backup() {
  if [ -e "$1$BACKUP_SUFFIX" ]; then
    mv "$1$BACKUP_SUFFIX" "$1"
    echo "  restored $1"
  fi
}

echo "Removing links"
for link in "${LINKS[@]}"; do
  target=${link#*|}
  if points_into_repo "$target"; then
    rm "$target"
    echo "  removed  $target"
    restore_backup "$target"
  elif [ -e "$target" ]; then
    echo "  skipped  $target (not a link into this repo)"
  fi
done

echo "Claude Code settings"
if [ -f "$CLAUDE_SETTINGS" ]; then
  if [ "$(cat "$CLAUDE_SETTINGS")" = "$(claude_settings)" ]; then
    rm "$CLAUDE_SETTINGS"
    echo "  removed  $CLAUDE_SETTINGS"
  else
    # Changed since install (e.g. by /config); keep a copy instead of losing those changes.
    mv "$CLAUDE_SETTINGS" "$CLAUDE_SETTINGS.dotfiles-old"
    echo "  moved    $CLAUDE_SETTINGS -> $CLAUDE_SETTINGS.dotfiles-old (it was changed after install)"
  fi
  restore_backup "$CLAUDE_SETTINGS"
fi

if [ "${1:-}" = "--include-local" ]; then
  echo "Removing machine-specific files"
  for file in "${LOCAL_FILES[@]}"; do
    target=${file#*|}
    if [ -e "$target" ]; then
      rm "$target"
      echo "  removed  $target"
    fi
  done
else
  echo "Kept machine-specific files (pass --include-local to delete them):"
  for file in "${LOCAL_FILES[@]}"; do
    target=${file#*|}
    if [ -e "$target" ]; then echo "  $target"; fi
  done
fi

echo "Done."
