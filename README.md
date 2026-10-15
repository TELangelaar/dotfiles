# dotfiles

Configs for PowerShell + Windows Terminal (Windows), zsh (Linux), oh-my-posh, Neovim, git and Claude Code.

## Install

```powershell
# Windows: needs Developer Mode (Settings > System > For developers) or an elevated shell
.\install.ps1             # link dotfiles
.\install.ps1 -Packages   # also install the tools via winget
```

```sh
# Linux
./install.sh              # link dotfiles
./install.sh --packages   # also install the tools (apt)
```

The install scripts are safe to re-run. Anything already at a target path is moved to `<name>.dotfiles-bak`.

## Dev tools

```powershell
.\devtools.ps1   # Windows, via winget
```

```sh
./devtools.sh    # Linux (Debian/Ubuntu), via apt and official installers
```

Installs Azure CLI, azd, Bicep, kubectl, kubelogin, Helm, k9s, kubectx/kubens, GitHub CLI, Docker (CLI on Windows, Engine on Linux), Atlassian CLI, .NET SDK 10 and 9 (with dotnet-ef, dotnet-coverage and hidi), Aspire CLI, Node.js LTS, uv, Rust, mkcert, SQLite, jq, yq, fzf, fd and bat. Safe to re-run: on Windows, winget upgrades what's already installed; on Linux, tools already on PATH are skipped.

## Remove

```powershell
.\remove.ps1                 # remove links, restore backups
.\remove.ps1 -IncludeLocal   # also delete the machine-specific files
```

```sh
./remove.sh
./remove.sh --include-local
```

Only symlinks that point into this repo are removed.

## What goes where

| Repo                                   | Windows                                                          | Linux                                    |
| -------------------------------------- | ---------------------------------------------------------------- | ---------------------------------------- |
| `powershell/Microsoft.PowerShell_profile.ps1` | `Documents\WindowsPowerShell\…` and `Documents\PowerShell\…` | –                                        |
| `windows-terminal/settings.json`       | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_…\LocalState` | –                                        |
| `zsh/.zshrc`                           | –                                                                | `~/.zshrc`                               |
| `oh-my-posh/theme.omp.json`            | `~/.config/oh-my-posh/theme.omp.json`                            | same                                     |
| `nvim/`                                | `%LOCALAPPDATA%\nvim`                                            | `~/.config/nvim`                         |
| `git/.gitconfig`, `git/ignore`         | `~/.gitconfig`, `~/.config/git/ignore`                           | same                                     |
| `git/windows.gitconfig` / `linux.gitconfig` | `~/.config/git/os.gitconfig`                                | same                                     |
| `claude/statusline-command.ps1` / `.sh` | `~/.claude/`                                                    | `~/.claude/`                             |
| `claude/skills/*`                      | `~/.claude/skills/*`                                             | same                                     |

## Machine-specific settings

This repo is public, so work- and machine-specific settings stay out of it. The install script creates these from the `*.example` templates if they don't exist, and never overwrites them:

| File                                      | Loaded by                     |
| ----------------------------------------- | ----------------------------- |
| `~/.config/powershell/profile.local.ps1`  | end of the PowerShell profile |
| `~/.zshrc.local`                          | end of `.zshrc`               |
| `~/.gitconfig.local`                      | `[include]` in `.gitconfig`   |
| `~/.config/claude/settings.local.json`    | merged into Claude settings   |

## Claude Code settings

Claude Code rewrites `~/.claude/settings.json` itself, which replaces a symlink with a regular file. Its `autoMode` block is also only read from that file. So instead of a link, the install script generates `~/.claude/settings.json` by deep-merging:

1. `claude/settings.json` (shared)
2. `claude/settings.windows.json` or `claude/settings.linux.json` (status line)
3. `~/.config/claude/settings.local.json` (hooks, env, autoMode; machine-specific)

Re-run the install script after editing any of these. If the generated file was changed in the meantime (for example by `/model`), the old one is kept as `settings.json.dotfiles-bak`; copy anything you want to keep into one of the layers.
