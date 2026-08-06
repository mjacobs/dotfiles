## Overview

Personal dotfiles managed with [yadm](https://yadm.io). Remote: <https://github.com/mjacobs/dotfiles>

## System

- **OS**: Fedora 44 (KDE Plasma Desktop Edition)
- **Shell**: zsh (primary), bash (fallback)

## Common Commands

```bash
yadm status
yadm add ~/.newfile
yadm commit -m "message"
yadm push
```

## Setting Up on a New Machine

### Prerequisites

yadm itself isn't in the Fedora repos — it needs Homebrew (Linuxbrew) first:

```bash
# Linuxbrew (non-interactive)
NONINTERACTIVE=1 /bin/bash -c \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install yadm
```

### Clone and checkout

```bash
yadm clone git@github.com:mjacobs/dotfiles.git
yadm config status.showUntrackedFiles no
```

`yadm clone` automatically runs `~/.config/yadm/bootstrap` afterward — see
[Bootstrap Script](#bootstrap-script) below. It installs everything else
(dnf packages, the rest of the Brewfile, mise, rustup, oh-my-zsh + its custom
plugins, TPM, a starter `~/.secrets`, and — if you already have the GPG key —
decrypts `.pgpass`/`rclone.conf`).

To re-run it later (e.g. after editing `~/.config/dnf-packages.txt`):

```bash
yadm bootstrap
```

### Manual follow-ups bootstrap can't do for you

- `gh auth login` (GitHub CLI auth; `.gitconfig` uses `gh` as its credential
  helper)
- Import the GPG signing/encryption key (fingerprint ends in
  `D787BA76BDB81BA1`) if it isn't already in your keyring, then
  `yadm decrypt`
- Fill in real values in `~/.secrets` (copied from
  `~/.config/secrets.template` — see [Secrets](#secrets) below)
- Create a per-machine `~/.zshrc.local` if this box needs overrides

## yadm Features

### Per-host Alternate Files

yadm can swap in different versions of a file based on hostname, OS, or other
conditions. Create alternate files alongside the original using `##` suffixes:

```
# Hostname-specific .zshrc overrides
~/.zshrc.local##hostname.baox       # used only on host "baox"
~/.zshrc.local##hostname.devbox     # used only on host "devbox"

# OS-specific gitconfig
~/.gitconfig##os.Linux
~/.gitconfig##os.Darwin

# Combine conditions (AND logic)
~/.config/aliases.sh##os.Linux,hostname.baox
```

When yadm checks out or runs `yadm alt`, it symlinks the best-matching
alternate to the base filename. Non-matching alternates are ignored.

Available selectors: `hostname`, `os`, `distro`, `distro_family`, `arch`,
`class` (user-defined via `yadm config local.class <name>`).

```bash
# See which alternates are active
yadm alt --list

# Set a custom class for grouping machines
yadm config local.class work    # then use  file##class.work
```

### Encrypted Files

yadm can encrypt sensitive files (API keys, SSH keys, etc.) in the repo using
GPG or age. The encrypted content is stored as a single blob
(`~/.local/share/yadm/archive`) that is safe to commit.

```bash
# 1. List patterns of files to encrypt in ~/.config/yadm/encrypt
cat ~/.config/yadm/encrypt
.secrets
.ssh/id_*
.ssh/config
!.ssh/*.pub          # exclude public keys

# 2. Encrypt the matched files into the archive
yadm encrypt

# 3. Commit the archive
yadm add ~/.local/share/yadm/archive
yadm commit -m "update encrypted files"

# 4. On another machine, after cloning:
yadm decrypt         # extracts files from the archive
```

By default yadm uses GPG. To use age instead:

```bash
yadm config yadm.cipher age
# age will prompt for a passphrase on encrypt/decrypt
```

### Bootstrap Script

`~/.config/yadm/bootstrap` (present, executable, idempotent) runs
automatically after `yadm clone` and can be re-run any time via
`yadm bootstrap`. In dependency order it:

1. `sudo dnf install -y` everything in `~/.config/dnf-packages.txt` (skips
   gracefully on non-Fedora)
2. Installs Linuxbrew if absent, then
   `brew bundle --file=~/.config/homebrew/Brewfile`
3. Installs mise (dnf/brew) if absent, then `mise install` (reads the tracked
   `~/.config/mise/config.toml`)
4. Installs rustup if `~/.cargo/bin/rustup` is absent
5. Installs oh-my-zsh unattended if absent, then clones the 5 required custom
   plugins (see [Oh-My-Zsh Plugins](#oh-my-zsh-plugins))
6. Clones TPM if absent and runs its `install_plugins`
7. Creates `~/.secrets` from `~/.config/secrets.template` if missing
   (chmod 600, placeholder values — you still need to fill it in)
8. Runs `yadm decrypt` if the GPG key is already in your keyring, otherwise
   prints instructions to import it first
9. Prints a summary of anything left to do by hand

Package manifests live in `~/.config/dnf-packages.txt` (dnf) and
`~/.config/homebrew/Brewfile` (Linuxbrew) — edit those, not the bootstrap
script, to add/remove packages.

## Architecture

### Key Files

- `~/.zshrc` - oh-my-zsh plugins, ssh-agent, homebrew, oh-my-posh prompt
- `~/.zshenv` - PATH additions (`.local/bin`, JetBrains, gcloud, bun, cargo)
- `~/.zprofile` - LANG, EDITOR
- `~/.config/zsh/` - OS-specific rc/env snippets sourced from `.zshrc`/`.zshenv`
- `~/.config/aliases.sh` - Custom aliases (sourced by .zshrc; interactive
  shells only — they do NOT apply in non-interactive/agent shells)
- `~/.config/nvim/` - Neovim config (LazyVim-based)
- `~/.gitconfig` - Git aliases, delta pager, gh credential helper
- `~/.tmux.conf` - Tmux config with TPM and tmux-powerkit
- `~/.config/mise/config.toml` - mise-managed runtimes/CLIs (currently:
  node, go, python, uv, poetry, gcloud, lazygit, lazydocker,
  markdownlint-cli2, prettier, and more — see the file for the full list)
- `~/.config/dnf-packages.txt` - dnf package manifest for bootstrap
- `~/.config/homebrew/Brewfile` - Linuxbrew package manifest for bootstrap
- `~/.config/secrets.template` - structure-only template for `~/.secrets`
- `~/.secrets` - API keys (NOT tracked; see [Secrets](#secrets))

### Oh-My-Zsh Plugins

`fzf`, `fzf-tab`, `git`, `history-substring-search`, `zsh-autosuggestions`,
`zsh-syntax-highlighting`, `zsh-shift-select`, `llm`

`fzf` and `git` ship with oh-my-zsh itself. The other 5 are custom plugins
cloned by the bootstrap script into `~/.oh-my-zsh/custom/plugins/`:

| Plugin                    | Source                                              |
| ------------------------- | ---------------------------------------------------- |
| `fzf-tab`                 | https://github.com/Aloxaf/fzf-tab                    |
| `zsh-autosuggestions`     | https://github.com/zsh-users/zsh-autosuggestions     |
| `zsh-syntax-highlighting` | https://github.com/zsh-users/zsh-syntax-highlighting |
| `zsh-shift-select`        | https://github.com/jirutka/zsh-shift-select          |
| `llm`                     | https://github.com/eliyastein/llm-zsh-plugin         |

## Interactive Shell

### History

- **HISTSIZE/SAVEHIST**: 100,000 entries (both in-memory and on-disk)
- **Key options**: `INC_APPEND_HISTORY` (write immediately),
  `HIST_FIND_NO_DUPS`, `HIST_IGNORE_ALL_DUPS`
- **Search**: Up/Down arrows use substring search, Ctrl+R uses fzf with preview

### Completion

- **fzf-tab**: Fuzzy completion with file previews (uses `bat` and `lsd`)
- **Grouping**: Completions grouped by type with colored headers
- **Navigation**: Use `<` and `>` to switch between completion groups
- **Auto-regenerated completions**: `.zshrc`'s `regen_zsh_completion_if_needed`
  generates zsh completions for tools whose binary is newer than the cached
  copy (agentsview, bd, docker, gh, kata, kubectl, mise, rustup/cargo,
  roborev, tailscale, yas, and more) into
  `${XDG_CACHE_HOME:-~/.cache}/zsh/completions`, prepended to `fpath`. This
  happens automatically on shell start — no manual step needed.
- **`~/.local/bin/refresh-completions`**: a force-regen escape hatch (wipes
  the cache and re-triggers the `.zshrc` logic) plus bash completion
  generation. Only needed if a completion looks stale and the mtime check
  above didn't catch it.

### Prompt

oh-my-posh, theme resolved at `.zshrc` load time (first match wins):

1. `~/.config/oh-my-posh/themes/` — custom Catppuccin Mocha themes, tracked
   in this repo (`mocha-evolution.omp.json` by default; others available)
2. oh-my-posh's own built-in default

Set `OMP_THEME_NAME` in `~/.zshrc.local` to pick a different theme per
machine. The prompt degrades gracefully (falls through to oh-my-posh's
built-in init) if `oh-my-posh` itself isn't installed. To try stock
oh-my-posh themes, browse <https://ohmyposh.dev/docs/themes> and drop a
`.omp.json` into the tracked themes dir. (The old `omp-manager` tool that
provided a local stock-theme set was retired 2026-07-08.)

### Notable Aliases

- `cat` → `bat`, `vim` → `nvim`, `ls` → `lsd`
- `c`/`v` → `wl-copy`/`wl-paste` (Wayland clipboard)
- `g` → glow (markdown reader), `j` → journalctl, `s` → systemctl

### GPG/SSH

Git commits/tags are signed with the **SSH key** `~/.ssh/id_ed25519` via
ssh-agent (`gpg.format=ssh` in `.gitconfig`) — no passphrase prompts, works in
non-interactive/agent shells. Local verification uses the tracked
`~/.config/git/allowed_signers`. The public key must be registered as a
*signing* key on each forge for "Verified" badges (GitHub:
`gh ssh-key add ~/.ssh/id_ed25519.pub --type signing`; Gitea: user settings →
SSH keys).

GPG is now used **only** for `yadm encrypt`/`decrypt` (key fingerprint
`63BFD09F75BA576EA641B245D787BA76BDB81BA1`, short ID `D787BA76BDB81BA1`). SSH
authentication uses ssh-agent (started in `.zshrc` if `$SSH_AUTH_SOCK` is
missing).

## Secrets

`~/.secrets` holds API keys/tokens and is sourced by `.zshrc`. It is
deliberately **not tracked** by yadm and never contains real values in this
repo — instead:

- `~/.config/secrets.template` (tracked) reproduces the variable names and
  section comments of `~/.secrets` with every value replaced by a
  `<from-bitwarden>` placeholder.
- On a machine with no `~/.secrets`, `yadm bootstrap` copies the template to
  `~/.secrets` (`chmod 600`) and prints a reminder to fill in real values.
- Keep `secrets.template` in sync by hand when you add a new key to
  `~/.secrets` — it's structure documentation, not generated.

Two files (`.pgpass`, `.config/rclone/rclone.conf`) go through yadm's GPG
encryption instead (see [Encrypted Files](#encrypted-files)) since they need
to round-trip through the repo itself rather than being freshly minted per
machine.
