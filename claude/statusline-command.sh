#!/usr/bin/env bash
# Claude Code status line script
# Receives session JSON on stdin; prints a compact status string.
# Linux counterpart of statusline-command.ps1. Requires jq.

raw=$(cat)

# --- 1. Basename of current working directory ---
cwd=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$raw" 2>/dev/null)
[ -z "$cwd" ] && cwd=$PWD
dir_name=$(basename "$cwd")

# --- 2. Git branch ---
branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)

# --- 3. Model display name ---
model=$(jq -r '.model.display_name // empty' <<<"$raw" 2>/dev/null)

# --- 4. Context usage ---
used=$(jq -r '.context_window.used_percentage // empty' <<<"$raw" 2>/dev/null)
ctx=""
[ -n "$used" ] && ctx="ctx $(printf '%.0f' "$used")%"

# --- Assemble parts ---
parts=()
for p in "$dir_name" "$branch" "$model" "$ctx"; do
  [ -n "$p" ] && parts+=("$p")
done

out=""
for p in "${parts[@]}"; do
  out+="${out:+  }$p"
done
echo "$out"
