# Stacked PRs: concepts and FAQ

Sources:
https://github.github.com/gh-stack/guides/stacked-prs/,
https://github.github.com/gh-stack/guides/ui/,
https://github.github.com/gh-stack/faq/

## Review experience

Each PR shows only the diff between its branch and the branch below it — a
PR for "API routes" shows only the API changes, not the auth middleware
from the layer below. Approving one PR in a stack doesn't affect the
others. To get the full picture, read the stack bottom-up; the stack
navigator (in the PR header on GitHub) shows all PRs in order, which one is
active, and lets reviewers jump between them.

## Creating a stack from the GitHub UI (no CLI)

1. Create the first PR normally, targeting the main branch.
2. For the next PR, set its base branch to the previous PR's branch and
   check "Create stack".
3. The stack navigator appears in the header once PRs are linked.

To add to an existing stack from the UI: open the stack icon in any PR
header → "Add" → the base branch is auto-set to the topmost PR's head →
confirm "Add to existing stack".

Unstacking (UI or `gh stack unstack`) dissolves the association; PRs become
independent and keep their current base branches.

## Merge mechanics

- Stacks merge bottom-up as a single atomic operation. Selecting a PR to
  merge lands that PR **and every unmerged PR below it** together, ordered
  bottom-up. PRs above stay open and are automatically rebased so the next
  unmerged PR's base targets `main` directly.
- To merge any PR, all PRs below it must also have passing checks and meet
  all merge requirements (reviews, CODEOWNERS, status checks).
- A fully linear history between branches is required. Fix non-linear
  history with `gh stack rebase` (CLI) or "Rebase Stack" (web UI, triggers
  a server-side cascading rebase that re-runs CI on affected PRs).
- Partial stack merges are supported — merging a subset from the bottom is
  fine; the rest of the stack rebases automatically afterward.
- Stacked PRs fully support merge queue: all PRs enter the queue in the
  correct order; removing one from the queue ejects everything above it.
  Stacks are kept in the same merge group on a best-effort basis.
- Closing a PR in the middle of a stack blocks every PR above it from
  merging. The stack relationship persists; restructure (unstack +
  recreate, or `gh stack modify`) to resolve it.
- If a merge error occurs partway through a stack merge, already-merged
  PRs stay landed; the failing PR and everything above it remain open for
  retry.
- Once a stack is fully merged it's done — it cannot be extended. New
  branches pushed later start a fresh stack rooted at trunk.

### Merge strategy semantics

- **Squash merge:** each PR produces one clean squashed commit; merging
  `n` PRs creates `n` squashed commits on the base branch (via `rebase
  --onto` under the hood).
- **Merge commit:** the whole group being merged gets **one** merge commit.
- **Rebase merge:** commits from each PR replay onto the base branch,
  keeping a fully linear history with no merge commits.

## Branch protection & CI

- Required reviews, required status checks, CODEOWNERS, and code scanning
  are all evaluated **as if every PR in the stack targets the base of the
  stack** (typically `main`), not each PR's immediate base branch.
- GitHub Actions workflows trigger the same way — a workflow configured to
  run on pushes/PRs against `main` runs for every PR in the stack, even
  though most PRs technically target another branch in the stack.
- Stack metadata is available in workflows via
  `github.event.pull_request.stack`, including `base.ref` and `base.sha`.

## Limitations

- All branches in a stack must live in the same repository — stacking
  across forks is not supported.
- Stacked PRs is in **private preview**; it must be enabled per-repository.
  Sign up at https://gh.io/stacksbeta.

## Interop with other stacking tools

The GitHub CLI extension is not required — stacked PRs are just standard
git branches and regular PRs with a linked base chain, manageable with
plain `git` and the GitHub UI. Other stacking tools (jj, Sapling,
git-town, etc.) work too, as long as they create PRs with the correct base
branches. Use `gh stack link <branch-or-pr> <branch-or-pr> [...]` to
connect externally-managed branches into a tracked stack.
