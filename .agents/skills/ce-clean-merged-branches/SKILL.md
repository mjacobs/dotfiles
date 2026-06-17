---
name: ce-clean-merged-branches
description: Clean up local branches (and their worktrees) whose upstream PR has already merged, in a fork-and-PR workflow where the maintainer squash-merges. Use when the user says "clean merged branches", "prune merged PRs", "clean up branches that merged upstream", "fork cleanup", or when `clean-gone` finds nothing but branches are clearly done. Detects merge state from GitHub PR status, not git's "[gone]" marker.
---

# Clean Merged Branches

Delete local branches whose **upstream pull request has merged**, including any
associated worktrees. This is the fork-workflow companion to
`ce-clean-gone-branches`.

## When to reach for this instead of `clean-gone`

`clean-gone` deletes branches git marks `[gone]` -- i.e. whose remote tracking
branch was deleted. That works when you own the remote and delete branches on
merge. It is **structurally blind** to the kenn.io-style fork workflow:

- `origin` = your fork, `upstream` = the maintainer's repo.
- The maintainer **squash-merges** your PR into `upstream`, often adding edits.
- Your branch's original commits never become reachable from `upstream`, and
  your local branch keeps tracking `origin/<branch>` (which still exists).
- So git never marks the branch `[gone]`, and `clean-gone` reports nothing --
  even though every branch is done.

The reliable signal here is the **GitHub PR state**, which is what this skill
reads. Tell-tale sign you want this skill: `clean-gone` says "no stale branches"
but `git worktree list` / `git branch` is full of finished work.

## Workflow

### Step 1: Scan branches against upstream PR state

```bash
bash scripts/scan-merged
```

[scripts/scan-merged](./scripts/scan-merged)

The script fetches `upstream`, pulls every PR once via `gh`, and prints a TSV row
per non-protected local branch (it always skips `main`/`master`/the upstream
default branch and the currently checked-out branch). Pass `owner/repo` to
override the repo it queries; by default it derives it from the `upstream`
remote, falling back to `origin`.

If it prints `__NONE__`, report that there's nothing to clean and stop. If it
errors that `gh` is missing or unauthenticated, relay that and stop -- this skill
cannot work without GitHub PR state.

Columns: `branch  worktree  pr  pr_state  ahead_origin  tip_upstream  scratch`.

### Step 2: Categorize each row

Apply these rules. Most rows are unambiguous; only a few need a look.

- **`pr_state=MERGED` -> DELETE.** The work is upstream. Remove the worktree (if
  any) and the branch.
  - `tip_upstream=no` is **normal** for a squash-merge -- not a red flag by
    itself.
  - If `ahead_origin` > 0, note it: "N commit(s) beyond `origin/<branch>` will be
    dropped." These are usually the pre-squash originals (already represented in
    the merge), but list the count so the user can veto.
  - **Verify-before-delete trigger:** if `pr_state=MERGED` **and**
    `tip_upstream=no`, glance at `git log --oneline <upstream-default>..<branch>`
    (e.g. `upstream/main..<branch>`). If those commits are just the branch's
    original work (squashed away), it's safe. If they contain *new* work added
    after the merge (a follow-up fix, or a revert of the merged change), move the
    branch to **KEEP** and flag it -- deleting would lose unmerged work.
- **`scratch=yes` and `pr_state` is `NONE`/`CLOSED` -> DELETE.** Throwaway
  branches (workflow worktrees `worktree-wf_*`, `TMP-*` graphs, `*-original`
  backups). If it's a `*-original` backup of a branch whose PR is MERGED, say so.
- **`pr_state=CLOSED` (not merged), not scratch -> ASK.** The PR was abandoned.
  Default to keeping unless the user says delete; mention it separately rather
  than bundling into the safe set.
- **`pr_state=OPEN` -> KEEP.** Active review in flight.
- **`pr_state=NONE`, not scratch -> KEEP.** Genuine unmerged local work that was
  never PR'd. Never delete these without explicit instruction.

### Step 3: Present the plan and confirm

Show the user the categorized result -- a DELETE list (branches + their
worktrees, each annotated with its PR number / reason) and a KEEP list (with the
one-line reason each is spared). Call out any verify-before-delete or
`ahead_origin` notes inline.

Then get confirmation with the platform's blocking question tool: `AskUserQuestion`
in Claude Code (load its schema first with `ToolSearch` `select:AskUserQuestion`
if needed), `request_user_input` in Codex, `ask_user` in Gemini/Pi. Fall back to
asking in chat only if no blocking tool exists. Never delete without asking.

Because this cleanup spans more than a flat yes/no, offer a small set of scoped
choices. **Every option label/description must carry the concrete counts** it
covers (`N branches`, `M worktrees`) -- the count is what makes the choice
legible. Build the option set from what's actually present, not a fixed list:

- **All merged + scratch** (default/recommended) -- e.g. "Delete all 17 branches
  + remove 7 worktrees." Always offer this when the DELETE list is non-empty.
- **Worktrees only** -- e.g. "Remove 7 worktrees + their branches; leave the 10
  branch-only merged ones." Offer only when some DELETE rows have worktrees and
  some don't.
- **Just scratch/workflow** -- e.g. "Conservative: only the 3 `wf_` worktrees + 2
  scratch branches." Offer only when scratch rows exist.

Surface the per-branch caveats in the plan *above* the question (not buried in an
option): any `ahead_origin` > 0 ("N commits beyond origin drop on delete") and
any verify-before-delete result. Keep `main`, OPEN PRs, and no-PR local work out
of every option. If the DELETE list collapses to nothing after categorization
(everything is KEEP), skip the question -- just report there's nothing to clean.

### Step 4: Delete confirmed items (worktrees first)

For each confirmed branch:

1. If it has a worktree (the `worktree` column, or `git worktree list | grep
   "\\[$branch\\]"`) and that path is not the main repo root, remove it first:
   `git worktree remove --force "$worktree_path"`.
1. Delete the branch: `git branch -D "$branch"`.

Then `git worktree prune` to clear stale admin refs. Report what was removed and,
in one line, note recoverability: merged branches still exist on `origin` and
every deleted ref is in the reflog, so this is reversible. Finish with the KEEP
list so the user sees what survived and why.

## Safety

- Never delete `main`/`master`, the upstream default branch, the checked-out
  branch, OPEN-PR branches, or `pr_state=NONE` non-scratch branches.
- The script only reads; all deletion happens in Step 4 after explicit
  confirmation.
- Match by PR head-branch name; the script prefers PRs from your fork's owner to
  avoid colliding with another contributor's identically named branch. If a
  branch's mapping looks wrong, verify with `gh pr view <n> --repo <upstream>`
  before acting.
