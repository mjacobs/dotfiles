## Overview

Personal dotfiles managed with [yadm](https://yadm.io). Remote: <https://github.com/mjacobs/dotfiles>

## System

- **OS**: Fedora 43 (KDE Plasma Desktop Edition)
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

```bash
brew install yadm fzf bat delta oh-my-posh neovim
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Clone and checkout

```bash
yadm clone git@github.com:mjacobs/dotfiles.git
yadm config status.showUntrackedFiles no
```

### Post-checkout

```bash
# oh-my-zsh custom plugins
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/le0me55i/zsh-shift-select ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-shift-select

# tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# then in tmux: prefix + I

# Create ~/.secrets with API keys (chmod 600, not tracked)
```

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

A `~/.config/yadm/bootstrap` script (if present and executable) runs
automatically after `yadm clone`. Use it to automate post-checkout setup:

```bash
#!/bin/bash
# ~/.config/yadm/bootstrap

# Install Homebrew packages
brew bundle --file="$HOME/.config/brew/Brewfile" || true

# Clone oh-my-zsh plugins
for repo in Aloxaf/fzf-tab zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting; do
  dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$(basename "$repo")"
  [[ -d "$dir" ]] || git clone "https://github.com/$repo" "$dir"
done

# tmux plugin manager
[[ -d ~/.tmux/plugins/tpm ]] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Decrypt secrets
yadm decrypt || echo "No encrypted archive found (expected on first setup)"
```

## Architecture

### Key Files

- `~/.zshrc` - oh-my-zsh plugins, ssh-agent, homebrew, oh-my-posh prompt
- `~/.zshenv` - PATH additions (`.local/bin`, JetBrains, gcloud, bun, cargo)
- `~/.zprofile` - LANG, EDITOR
- `~/.config/aliases.sh` - Custom aliases (sourced by .zshrc)
- `~/.config/nvim/` - Neovim config (LazyVim-based)
- `~/.gitconfig` - Git aliases, delta pager, gh credential helper
- `~/.tmux.conf` - Tmux config with TPM and tmux-powerkit
- `~/.secrets` - API keys (NOT tracked)

### Oh-My-Zsh Plugins

`fzf`, `fzf-tab`, `git`, `history-substring-search`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-shift-select`
