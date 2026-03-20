## Overview

Personal dotfiles managed with a bare git repo at `~/.dotfiles`. Remote: <https://github.com/mjacobs/dotfiles>

## System

- **OS**: Fedora 42 (KDE Plasma Desktop Edition)
- **Host**: private-host
- **Shell**: zsh (primary), bash (fallback)

## Common Commands

```bash
# The 'dotfiles' alias is defined in ~/.config/aliases.sh
dotfiles status
dotfiles add ~/.newfile
dotfiles commit -m "message"
dotfiles push

# Or without the alias:
git --git-dir=$HOME/.dotfiles --work-tree=$HOME <command>
```

## Architecture

### Zsh Configuration Load Order

1. `.zshenv` - PATH setup, nvm initialization (runs for all shells)
2. `.zprofile` - Environment vars like LANG, EDITOR (login shells)
3. `.zshrc` - Interactive shell config: oh-my-zsh, plugins, aliases

### Key Files

- `~/.zshrc` → oh-my-zsh plugins, GPG/SSH agent setup, homebrew, oh-my-posh prompt
- `~/.zshenv` → PATH additions (`.local/bin`, JetBrains, gcloud, bun, cargo)
- `~/.config/aliases.sh` → Custom aliases including `dotfiles` (sourced by .zshrc)
- `~/.config/nvim/` → Neovim config (LazyVim-based)
- `~/.gitconfig` → Git aliases (`lg`, `l1-l5`), delta pager, gh credential helper
- `~/.tmux.conf` → Tmux config with TPM and tmux-powerkit (catppuccin mocha theme)
- `~/.secrets` → API keys (NOT tracked - create manually on new machines)

### Oh-My-Zsh Plugins (in order)

`fzf`, `fzf-tab`, `git`, `history-substring-search`, `zsh-autosuggestions`, `zsh-syntax-highlighting`

Custom plugins are in `~/.oh-my-zsh/custom/plugins/`.

### History Configuration

- **HISTSIZE/SAVEHIST**: 100,000 entries (both in-memory and on-disk)
- **Key options**: `INC_APPEND_HISTORY` (write immediately), `HIST_FIND_NO_DUPS`, `HIST_IGNORE_ALL_DUPS`
- **Search**: Up/Down arrows use substring search, Ctrl+R uses fzf with preview

### Completion Configuration

- **fzf-tab**: Fuzzy completion with file previews (uses `bat` and `lsd`)
- **Grouping**: Completions grouped by type with colored headers
- **Navigation**: Use `<` and `>` to switch between completion groups

### Prompt

Uses oh-my-posh with theme at `~/.cache/oh-my-posh/themes/kushal.omp.json`.

### Secrets Management

API keys are in `~/.secrets` (chmod 600), sourced by `.zshrc`. This file is gitignored and must be created manually on each machine.

### Notable Aliases

- `dotfiles` → git commands for the bare dotfiles repo
- `cat` → `bat`, `vim` → `nvim`, `ls` → `lsd`
- `c`/`v` → xclip copy/paste
- `g` → glances, `j` → journalctl, `s` → systemctl

### GPG/SSH

SSH authentication uses gpg-agent (not ssh-agent). The socket is at `$(gpgconf --list-dirs agent-ssh-socket)`.

## Development Environment

### Languages & Version Managers

- **Node.js**: via nvm (managed in `.zshenv`)
- **Rust**: via rustup, cargo in `~/.cargo/bin`
- **Go**: via gvm (sourced in `.zshrc`)
- **Python**: system python3 + Linuxbrew

### Package Managers

- **System**: dnf (Fedora)
- **Homebrew**: Linuxbrew at `/home/linuxbrew/.linuxbrew`
- **Node**: pnpm (preferred), bun available
- **Rust**: cargo

### Project Directories

- `~/dev/` - Main development directory across all projects (largely unrelated to one another)

## Tool Preferences

### Modern CLI Replacements

Prefer modern rust/go alternatives to classic Unix tools:

- `bat` instead of `cat` (syntax highlighting)
- `lsd` instead of `ls` (icons, colors)
- `delta` for git diffs (side-by-side, syntax highlighting)
- `fzf` for fuzzy finding everywhere
- `glow` for markdown rendering (`catt`/`catp` aliases)
- `glances` for system monitoring (`g` alias), but `btop` preferred for general usage.

### Editor

- **Primary**: Neovim with LazyVim configuration
- **Vim keybindings**: enabled in zsh (vi-mode)

### Git Workflow

- `pull.rebase = true` - always rebase on pull
- `merge.conflictstyle = zdiff3` - better conflict markers
- `gh` CLI for GitHub authentication
- Useful aliases: `lg` (graph log), `l1`-`l5` (various log formats), `gsp` (stash-pull-pop)

## Setting Up on a New Machine

### Prerequisites

```bash
# ensure required tools are available
brew install fzf bat delta oh-my-posh neovim
```

Also, install rust/cargo:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### dotfiles setup

```bash
# Clone the bare repo
git clone --bare git@github.com:mjacobs/dotfiles.git $HOME/.dotfiles

# Define the alias temporarily
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Checkout the files (backup any existing files first)
dotfiles checkout

# Hide untracked files
dotfiles config status.showUntrackedFiles no

# Install TPM and tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Then in tmux, press prefix + I to install plugins

# Create ~/.secrets with your API keys
```

Clone zsh plugins:

```bash
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```
