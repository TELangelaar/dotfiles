# gh-stack CLI reference

Source: https://github.github.com/gh-stack/reference/cli/

Install: `gh extension install github/gh-stack` (requires `gh` v2.0+, uses
existing `gh auth login` credentials).

## Stack management

### `gh stack init`

```
gh stack init [flags] [branches...]
```

Initialize a new stack in the current repository. Creates new branches or
adopts existing ones. Enables `git rerere` automatically.

- `-b, --base <branch>` — trunk branch (defaults to repo default branch)

### `gh stack add`

```
gh stack add [flags] [branch]
```

Add a new branch on top of the current stack.

- `-A, --all` — stage all changes including untracked files (requires `-m`)
- `-u, --update` — stage tracked files only (requires `-m`)
- `-m, --message <string>` — create a commit before adding the branch

`-A` and `-u` are mutually exclusive.

### `gh stack view`

```
gh stack view [flags]
```

Show the current stack's branches, ordering, and PR links.

- `-s, --short` — compact output (branch names only)
- `--json` — output stack data as JSON

### `gh stack checkout`

```
gh stack checkout [<stack-number> | <pr-number> | <pr-url> | <branch>]
```

Switch to a stack by number, PR number, PR URL, or branch name. Fetches
remote stacks if needed. Runs an interactive picker with no arguments.

### `gh stack modify`

```
gh stack modify [flags]
```

Interactive terminal UI to restructure the current stack locally.

- `--continue` — resume after resolving conflicts
- `--abort` — cancel and restore previous state

Keybindings inside the UI:

| Operation     | Key         | Effect                                             |
|---------------|-------------|-----------------------------------------------------|
| Drop          | `x`         | Remove branch and its commits                       |
| Fold down     | `d`         | Cherry-pick commits into the branch below, remove this one |
| Fold up       | `u`         | Absorb commits into the branch above                |
| Insert below  | `i`         | Insert new empty branch below cursor (name at apply) |
| Insert above  | `I`         | Insert new empty branch above cursor                 |
| Move down     | `Shift+↓`   | Reorder branch toward trunk                          |
| Move up       | `Shift+↑`   | Reorder branch away from trunk                       |
| Rename        | `r`         | Change branch name (pushed on next submit)           |
| Undo          | `z`         | Undo last staged action                              |
| Apply         | `Ctrl+S`    | Execute all staged modifications                     |

If applying triggers rebase conflicts: resolve in editor, `git add` the
files, then `gh stack modify --continue`.

### `gh stack unstack`

```
gh stack unstack [<stack-number>] [flags]
```

Remove a stack from local tracking and unstack it on GitHub (PRs become
independent, keeping their current base branches).

- `--local` — only remove local tracking, preserve the stack on GitHub

## Remote operations

### `gh stack submit`

```
gh stack submit [flags]
```

Push branches and create/update PRs and the Stack on GitHub.

- `--auto` — skip the editor, use auto-generated PR titles
- `--open` — create new PRs as ready for review instead of drafts
- `--remote <name>` — remote to push to

### `gh stack sync`

```
gh stack sync [flags]
```

Fetch, rebase, push, and sync PR state in one command. Process: fetch →
reconcile remote stack → fast-forward trunk → cascade rebase → push → sync
PR state → sync stack → prune (if requested).

- `--remote <name>` — remote for fetch/push
- `--prune` — delete local branches for merged PRs

### `gh stack rebase`

```
gh stack rebase [flags] [branch]
```

Pull from remote and cascade-rebase across the stack.

- `--downstack` — only rebase branches from trunk to the current branch
- `--upstack` — only rebase branches from the current branch to the top
- `--no-trunk` — skip trunk; only rebase stack branches
- `--continue` — resume after resolving conflicts
- `--abort` — undo the entire rebase
- `--remote <name>` — remote to fetch from
- `--committer-date-is-author-date` (alias `--preserve-dates`) — preserve dates during rebase

### `gh stack push`

```
gh stack push [flags]
```

Push all branches in the current stack to the remote (force-with-lease, no
PR updates).

- `--remote <name>` — remote to push to

### `gh stack link`

```
gh stack link [flags] <stack-number | branch-or-pr> <branch-or-pr> [...]
```

Link existing PRs into a stack on GitHub without local tracking — for
branches created with another tool (jj, Sapling, git-town, etc.).

- `--base <branch>` — base branch for the bottom of the stack (default `main`)
- `--open` — mark PRs as ready for review
- `--remote <name>` — remote to push to

## Navigation

| Command | Syntax | Effect |
|---|---|---|
| `gh stack switch` | `gh stack switch` | Interactive picker to switch branch within the stack |
| `gh stack up` | `gh stack up [n]` | Move toward the top of the stack |
| `gh stack down` | `gh stack down [n]` | Move toward the bottom of the stack |
| `gh stack top` | `gh stack top` | Jump to the topmost branch |
| `gh stack bottom` | `gh stack bottom` | Jump to the bottommost branch |
| `gh stack trunk` | `gh stack trunk` | Jump to the trunk branch |

## Utility

### `gh stack alias`

```
gh stack alias [flags] [name]
```

Create a command alias (e.g. `gs`) for faster typing.

- `--remove` — remove a previously created alias

### `gh stack feedback`

```
gh stack feedback [title]
```

Share feedback via a GitHub Discussion.

## Environment variables

| Variable | Values | Purpose |
|---|---|---|
| `GH_STACK_THEME` | `auto`, `light`, `dark` | Controls interactive screen color palette |

## Exit codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | Generic error |
| 2 | Not in a stack / stack not found |
| 3 | Rebase conflict |
| 4 | GitHub API failure |
| 5 | Invalid arguments or flags |
| 6 | Disambiguation required |
| 7 | Rebase already in progress |
| 8 | Stack locked by another process |
| 9 | Stacked PRs not enabled for repository |
