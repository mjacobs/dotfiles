# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in
this home directory and its dotfiles.

## Critical: This is a yadm Repo

The home directory is **not** a plain git repo — dotfiles are managed with
[yadm](https://yadm.io) (remote: <https://github.com/mjacobs/dotfiles>). Never
`git init` here. Use yadm for all dotfile version control:

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
- **Host**: private-host
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
- `~/.config/aliases.sh` → Custom aliases (sourced by .zshrc; interactive
  shells only — they do NOT apply in non-interactive/agent shells)
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
- GPG is used for commit signing only; SSH auth uses ssh-agent
- Wrap commit message body text at 80 columns

## Tool Preferences

- Editor: Neovim (LazyVim). When suggesting tooling, prefer modern
  alternatives already installed: `bat`, `lsd`, `delta`, `fzf`, `glow`,
  `btop`.

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
