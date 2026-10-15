# Shared definitions for install.sh and remove.sh (Linux). Meant to be sourced.

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BACKUP_SUFFIX=.dotfiles-bak

# "repo path|target path" pairs. Each target becomes a symlink into the repo.
LINKS=(
  "zsh/.zshrc|$HOME/.zshrc"
  "oh-my-posh/theme.omp.json|$HOME/.config/oh-my-posh/theme.omp.json"
  "nvim|$HOME/.config/nvim"
  "git/.gitconfig|$HOME/.gitconfig"
  "git/ignore|$HOME/.config/git/ignore"
  "git/linux.gitconfig|$HOME/.config/git/os.gitconfig"
  "claude/statusline-command.sh|$HOME/.claude/statusline-command.sh"
)
for skill in "$REPO"/claude/skills/*/; do
  name=$(basename "$skill")
  LINKS+=("claude/skills/$name|$HOME/.claude/skills/$name")
done

# "example|target" pairs. Copied once, never overwritten, never committed.
LOCAL_FILES=(
  "zsh/zshrc.local.example|$HOME/.zshrc.local"
  "git/gitconfig.local.example|$HOME/.gitconfig.local"
  "claude/settings.local.example.json|$HOME/.config/claude/settings.local.json"
)

# Claude Code rewrites its settings.json (which breaks symlinks), so it is generated instead:
# claude/settings.json, overlaid with claude/settings.linux.json and the local settings.
CLAUDE_SETTINGS=$HOME/.claude/settings.json
CLAUDE_LAYERS=("$REPO/claude/settings.json" "$REPO/claude/settings.linux.json" "$HOME/.config/claude/settings.local.json")

points_into_repo() {
  [ -L "$1" ] && [[ "$(readlink "$1")" == "$REPO"/* ]]
}

claude_settings() {
  local layers=()
  for layer in "${CLAUDE_LAYERS[@]}"; do
    [ -f "$layer" ] && layers+=("$layer")
  done
  if command -v jq >/dev/null; then
    jq -s 'reduce .[] as $x ({}; . * $x)' "${layers[@]}"
  else
    python3 - "${layers[@]}" <<'PY'
import json, sys
def merge(base, overlay):
    for key, value in overlay.items():
        if isinstance(value, dict) and isinstance(base.get(key), dict):
            merge(base[key], value)
        else:
            base[key] = value
    return base
merged = {}
for path in sys.argv[1:]:
    with open(path, encoding="utf-8") as f:
        merge(merged, json.load(f))
print(json.dumps(merged, indent=2, ensure_ascii=False))
PY
  fi | sed "s|{{HOME}}|$HOME|g"
}
