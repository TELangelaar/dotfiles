---
name: github-stacked-prs
description: This skill should be used when the user asks to "stack PRs", "create a stacked PR", "split this into a stack", "use gh stack", "break up a large PR into a stack", or mentions GitHub Stacked PRs, gh-stack, or wants to manage a chain of dependent pull requests where each PR targets the branch below it. Covers the gh-stack CLI, stack structuring, rebasing, and merge mechanics.
---

# GitHub Stacked PRs

Stacked PRs let a large change be submitted as an ordered chain of small pull
requests, where each PR targets the branch of the PR below it instead of
targeting `main` directly. Reviewers see only the diff for their layer;
merging happens bottom-up.

Source docs: https://github.github.com/gh-stack/

## Core workflow

```sh
cd my-project
gh stack init                          # names the first branch; trunk = repo default branch
# ... write code ...
git add . && git commit -m "Add auth middleware"

gh stack add api-routes                # adds a new branch on top of the stack
# ... write code ...
git add . && git commit -m "Add API routes"

gh stack push                          # push all branches (force-with-lease, no PR changes)
gh stack submit                        # create/update PRs, link them as a Stack on GitHub
gh stack view                          # show branches, PR links, statuses
```

Each PR gets the correct base automatically — the first branch targets
`main`, `api-routes` targets the first branch — so each PR's diff is just
that layer.

Shortcut: `gh stack alias` can bind `gh stack` to `gs`, and `gs add -Am
"message"` stages, commits, and adds a branch in one step (`-A` stages
everything including untracked files, `-u` stages tracked files only; both
require `-m`).

## Structuring a stack

- Foundational changes go in lower branches, dependent changes go higher —
  the stack should read as a logical narrative bottom-up.
- Start a new branch when the concern changes (backend → frontend), the
  reviewer audience changes, or a branch has grown too large.
- All branches in one stack should belong to the same feature/project.
  Unrelated work starts a separate stack.

## Making changes to a lower branch after building higher ones

```sh
gh stack down                 # or: gh stack checkout <branch>
# ... fix the code ...
git add . && git commit -m "Address review feedback"
gh stack rebase --upstack     # cascades the fix through branches above it
gh stack top                  # jump back to the branch being worked on
gh stack push                 # force-with-lease push
```

Navigation helpers: `gh stack up [n]` / `gh stack down [n]` / `gh stack top`
/ `gh stack bottom` / `gh stack trunk` / `gh stack switch` (interactive
picker).

## Keeping a stack in sync

`gh stack sync` is the all-in-one command: fetch → reconcile remote stack →
fast-forward trunk → cascade-rebase remaining branches → push → sync PR
state → optionally prune branches for merged PRs (`--prune`). Run it
whenever PRs below the current work have merged.

For rebasing alone, `gh stack rebase` replays each branch atop the one
below it. Useful flags:

- `--downstack` — only rebase from trunk to the current branch
- `--upstack` — only rebase from the current branch to the top
- `--no-trunk` — skip trunk, only rebase stack branches
- `--continue` / `--abort` — resume or cancel after resolving conflicts

On conflict: resolve markers, `git add` the files, then
`gh stack rebase --continue`.

Prefer CLI rebasing over the web UI's "Rebase Stack" button when commits
must stay signed (GPG/SSH) — the web UI rebase sets the committer without
signing.

## Restructuring a stack

`gh stack modify` opens an interactive terminal UI to reorder, drop, fold,
insert, or rename branches without recreating the stack from scratch. See
`references/cli-reference.md` for the full keybinding table. Apply staged
changes with `Ctrl+S`, then run `gh stack submit` to push the result and
update the remote stack.

## Merge mechanics (what to tell users who ask "why can't I merge this PR?")

- Merging is bottom-up and atomic: selecting a PR to merge lands it **and
  every unmerged PR below it** in one operation; PRs above stay open and
  auto-rebase onto the new base.
- To merge a PR, every PR below it must already meet all merge
  requirements (reviews, checks, CODEOWNERS) — a middle PR can't jump the
  queue.
- Branch protection and required checks are evaluated against the **base of
  the whole stack** (e.g. `main`), not each PR's immediate base branch —
  same for GitHub Actions triggers.
- A fully linear history between branches is required; use `gh stack
  rebase` (CLI) or "Rebase Stack" (web UI) if history diverges.
- Partial stack merges are supported. Stacked PRs work with merge queue.
- Closing a PR in the middle of the stack blocks every PR above it from
  merging until the stack is restructured.

Full FAQ detail (squash/merge-commit/rebase-merge semantics, forks, closing
mid-stack PRs, merge-queue behavior) is in `references/concepts-faq.md`.

## Reference files

- **`references/cli-reference.md`** — every `gh stack` subcommand, flags,
  the `gh stack modify` keybindings, environment variables, and exit codes.
- **`references/concepts-faq.md`** — full FAQ: merge semantics, branch
  protection/Actions interaction, fork limitations, third-party tool
  compatibility (jj, Sapling, git-town via `gh stack link`).
