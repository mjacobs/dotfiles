# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles managed with a bare git repo at `~/.dotfiles`. Remote: https://github.com/mjacobs/dotfiles

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

### Prompt
Uses oh-my-posh with theme at `~/dev/productivity/oh-my-posh/themes/kushal.omp.json`.

### Secrets Management
API keys are in `~/.secrets` (chmod 600), sourced by `.zshrc`. This file is gitignored and must be created manually on each machine.

### Notable Aliases
- `dotfiles` → git commands for the bare dotfiles repo
- `cat` → `bat`, `vim` → `nvim`, `ls` → `lsd`
- `c`/`v` → xclip copy/paste
- `g` → glances, `j` → journalctl, `s` → systemctl

### GPG/SSH
SSH authentication uses gpg-agent (not ssh-agent). The socket is at `$(gpgconf --list-dirs agent-ssh-socket)`.

### Named Directories
`~srv` → `/mnt/data1/scratch`

## Setting Up on a New Machine

```bash
# Clone the bare repo
git clone --bare https://github.com/mjacobs/dotfiles.git $HOME/.dotfiles

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
