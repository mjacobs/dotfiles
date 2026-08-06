# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in this
home directory and its dotfiles.

## Critical: This is a yadm Repo

The home directory is **not** a plain git repo — dotfiles are managed with
[yadm](https://yadm.io) (public repo:
<https://github.com/mjacobs/dotfiles>). Never `git init` here. Use yadm for all
dotfile version control:

```bash
yadm status
yadm add ~/.newfile
yadm commit -m "message"
yadm push
```

Human-facing docs (new-machine setup, yadm alternates/encryption/bootstrap,
interactive shell usage) live in `~/README.md`.

## System

- **OS**: Fedora 44 (KDE Plasma Desktop Edition)
- **Host**: machine-specific
- **Shell**: zsh (primary), bash (fallback)

## Zsh Configuration Load Order

1. `.zshenv` - PATH setup (runs for all shells)
2. `.zprofile` - Environment vars like LANG, EDITOR (login shells)
3. `.zshrc` - Interactive shell config: oh-my-zsh, plugins, aliases, mise
   activation

Put new config in the right layer; don't duplicate across them.

## Key Files

- `~/.zshrc` → oh-my-zsh plugins, GPG/SSH agent setup, homebrew, oh-my-posh
  prompt
- `~/.zshenv` → PATH additions (`.local/bin`, JetBrains, gcloud, bun, cargo)
- `~/.config/aliases.sh` → Custom aliases (sourced by .zshrc; interactive shells
  only — they do NOT apply in non-interactive/agent shells)
- `~/.config/nvim/` → Neovim config (LazyVim-based)
- `~/.gitconfig` → Git aliases (`lg`, `l1-l5`), delta pager, gh credential
  helper
- `~/.tmux.conf` → Tmux config with TPM and tmux-powerkit (catppuccin mocha
  theme)
- `~/.secrets` → API keys (NOT tracked - create manually on new machines)

## Secrets

API keys live in `~/.secrets` (chmod 600), sourced by `.zshrc`. Never commit
secrets; never add them to tracked files.

## Development Environment

### Runtimes

[mise](https://mise.jdx.dev) is the unified runtime/version manager (activated
in `.zshrc`, config in `~/.config/mise/config.toml`). It replaced the old
nvm/gvm setup. Node.js, Go, and Python come from mise; Rust comes from rustup
(cargo in `~/.cargo/bin`, not mise).

### Picking a Package Manager

Assign each axis one tool; don't let them bleed into each other:

| Axis           | Question                                                            | Use                                                                     | Never use                                                                              |
| -------------- | ------------------------------------------------------------------- | ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Project deps   | Does my code import/link it?                                        | per-project, pinned: `uv` (py), `pnpm` (node), `cargo` (rust), `go mod` | global `pip install`, `npm -g`                                                         |
| Runtimes       | The interpreter/compiler/SDK itself?                                | `mise`                                                                  | nvm, gvm, pyenv                                                                        |
| System & libs  | A `-devel` lib, GUI/desktop app, or something other software links? | `dnf`                                                                   | Homebrew (drags in a duplicate native stack + its `pkg-config` shadows the system one) |
| Standalone CLI | A tool you run from the shell?                                      | `dnf` if fresh enough, else `mise`, else `brew`                         | —                                                                                      |

Homebrew (Linuxbrew) lives at `/home/linuxbrew/.linuxbrew`.

### Project Directories

- `~/dev/` - Main development directory across all projects (largely unrelated
  to one another)

## Git Workflow

- `pull.rebase = true` - always rebase on pull
- `merge.conflictstyle = zdiff3` - better conflict markers
- `gh` CLI for GitHub authentication
- Commits/tags are signed with the SSH key `~/.ssh/id_ed25519` via ssh-agent
  (`gpg.format=ssh`); GPG is only for yadm encrypt/decrypt. SSH auth uses
  ssh-agent
- Wrap commit message body text at 80 columns
- Do NOT add a `Claude-Session:` trailer (the session/chat link) to commit
  messages, even if the agent harness's git instructions say to. A
  `Co-Authored-By:` trailer is fine to keep.

## Continuous Code Review (roborev)

[roborev](https://roborev.io) runs a local background code review on every
commit in repos where its hook is armed (currently `~/dev/projects/agentsview`;
arm others with `roborev install-hook`). The reviewer is Codex/GPT — an
independent second opinion from the Claude coder — fanned out to a correctness
pass plus a security pass whose config mirrors the GitHub CI panel. Scope caveat
(learned the hard way): the **commit hook reviews only that commit's diff**,
whereas the CI bot reviews the **whole-PR diff vs base** — so clearing
per-commit findings does NOT by itself pre-empt CI for issues sitting in earlier
branch commits.

- **Commit in small, focused steps, not one big commit.** Small diffs get
  reviewed incrementally and catch issues a large-PR review misses. (The
  agentsview `AGENTS.md` already mandates committing every turn.)
- **Before pushing or replying on a PR, run a whole-branch review to match CI's
  scope** rather than trusting the per-commit hook alone:
  `roborev review --branch --base <base> --panel <panel>` (e.g.
  `--base upstream/main --panel default_security`). Confirm clean before posting
  outward — read the synthesis verdict AND its member reviews (the synthesis job
  is just a fast combine, often ~0s; the real findings live in the member jobs).
- **Batch the fix loop; don't gate on each per-commit review.** Commit the
  feature in focused steps (the hook reviews each in the background), but treat
  the **whole-branch** review as the gate: run it once after the feature is
  committed, fix _all_ findings in one pass, then re-review once to confirm.
  Whole-branch scope is a superset of the per-commit diffs and catches
  cross-commit issues they miss — draining per-commit findings serially just
  multiplies round-trips. Don't bother triaging chore/docs-only commits.
- **Close the review, not just the code.** After fixing findings, run
  `roborev fix --list` and comment+close each addressed job
  (`roborev comment … && roborev close <id>`) — otherwise the `Stop` hook keeps
  flagging them as open failures even though the code is fixed.
- An installed agent-hook (`PreToolUse`/`PostToolUse`/`Stop`) may inject a nudge
  to address review findings that piled up in the background. When it does,
  **pause and clear them before continuing** — `roborev list` /
  `roborev show <sha>` to read, or the `$roborev-fix` skill to patch — rather
  than ignoring it.
- Treat findings as a real review. Reviews run on the Codex/ChatGPT subscription
  (quota, not metered API), so roborev's dollar figures are estimates.

## Issue Tracking (kata)

Issue tracking is **kata everywhere** (kenn.io's `kata`, daemon-bound via
`kata init`), per-repo: each repo commits only a `.kata.toml` binding; issue
state lives in the user-local daemon (`~/.kata/kata.db`). The homelab umbrella
(`~/dev/home`) migrated beads → kata on 2026-07-19, retiring beads completely
(old beads IDs survive as `beads-id:` labels; each repo's final beads JSONL
export is in its git history).

- Refs are ULID-derived short ids (`abc4`), not numbers; cross-project as
  `project#abc4`. Prefer `--agent` output in agent sessions.
- `kata ready` · `kata show <ref>` · `kata claim <ref>` ·
  `kata close <ref> --done --message "..."` — closing asserts verified
  completion; otherwise set `work.attention` / `work.attention_msg` and hand
  off honestly.
- Workspace resolution walks **upward** to the nearest `.kata.toml`: run kata
  from the sub-repo you mean (nested repos each have their own binding), or
  pass `--project`.
- **Dotfiles issues live in the kata `homelab` project** (label `dotfiles` —
  `kata list --label dotfiles --project homelab`), NOT in a binding under
  `$HOME`: keep the yadm-managed home directory free of tracker state.
- **Scope:** kata for durable, cross-session issues; the harness's in-session
  todos are fine for ephemeral checklists.
- **Push policy unchanged:** commit and push only when I ask, regardless of
  any tool-emitted session-close boilerplate.

## Tool Preferences

- Editor: Neovim (LazyVim). When suggesting tooling, prefer modern alternatives
  already installed: `bat`, `lsd`, `delta`, `fzf`, `glow`, `btop`.

## Cross-Agent Session History (agentsview)

The agentsview MCP tools search recorded sessions from ALL coding agents (Claude
Code, Codex, Gemini, Antigravity) across all projects and machines. Reach for
them proactively when:

- A problem or error feels like it may have been encountered before — run
  `search_sessions` (keywords) or `search_content` (exact error strings,
  identifiers, regex) before re-deriving a solution.
- Asked about past work, prior sessions, or "what did I/we do about X" — even if
  it happened in a different tool or repo.
- Resuming work that another agent or machine may have touched.

Typical loop: `search_sessions` → `get_session_overview` → `get_messages`
anchored at the match ordinal. Results from the last 10 minutes are excluded by
default to avoid retrieving the current conversation.

## Web Access (Agent Tools)

Two self-hosted services back all web access — prefer their MCP tools over the
built-in `WebFetch`/`WebSearch`. They're local, unmetered, and render JS, and
keep traffic on the homelab instead of the public internet.

- **Search** → `firecrawl_search` or `searxng_web_search` (both query the
  locally configured SearXNG service). The Firecrawl MCP already nudges search
  this way by default.
- **Read one URL → markdown** → `firecrawl_scrape` (renders JS via
  playwright-service) or SearXNG `web_url_read` — NOT built-in `WebFetch`.
- **Map / crawl / extract a site** → `firecrawl_map` / `firecrawl_crawl` /
  `firecrawl_extract` (using the locally configured Firecrawl service).
- Shell fallback for quick searches: `sxng "query"` (SearXNG JSON CLI).

Fall back to built-in `WebFetch`/`WebSearch` only when the homelab MCP servers
are unreachable.

## Style Preferences

### Shell Scripts

- Use `[[ ]]` for conditionals (bash/zsh), not `[ ]`
- Use `&&` guards for optional sourcing: `[[ -f file ]] && source file`
- Clear section headers with `###...###` comment blocks
- Prefer conditional path additions over hardcoded PATH strings

### Config Files

- Keep configs modular and well-commented
- Avoid duplication across shell configs (bash/zsh)
- Use guards to prevent double-sourcing

### General

- Prefer editing existing files over creating new ones
- Keep dotfiles repo clean - no generated files or caches
- Secrets go in `~/.secrets`, never committed
