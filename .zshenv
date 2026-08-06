# Tie the PATH variable to the unique 'path' array
typeset -U path
path+=("${HOME}/.bun/bin")
path+=("${HOME}/.lmstudio/bin")
path+=("${HOME}/.local/bin")
path+=("${HOME}/.local/share/pnpm")
path+=("${HOME}/.local/share/pnpm/bin")
path+=("${HOME}/go/bin")

# Ensure the final PATH variable is exported for subprocesses
export PATH

## pnpm needs this env var for global installs
# export PNPM_HOME="${HOME}/.local/share/pnpm"
# export PNPM_BIN="${HOME}/.local/share/pnpm/bin"
# case ":$PATH:" in
# *":$PNPM_HOME:"*) ;;
# *) export PATH="$PNPM_HOME:$PNPM_BIN:$PATH" ;;
# esac

################################################################################
# OS-specific env (Homebrew, Java, Android, extra PATH entries)
################################################################################
case "$OSTYPE" in
darwin*) [[ -f "${HOME}/.config/zsh/env.macos.zsh" ]] && source "${HOME}/.config/zsh/env.macos.zsh" ;;
linux*) [[ -f "${HOME}/.config/zsh/env.linux.zsh" ]] && source "${HOME}/.config/zsh/env.linux.zsh" ;;
esac

# cargo/rustup — prepends ~/.cargo/bin (after brew shellenv so cargo actually
# wins over any same-named brew binary)
[[ -s "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# mise shims — prepended LAST so mise-managed runtimes (node, go, python, uv…)
# beat brew/system in EVERY shell, including non-interactive/agent shells where
# `mise activate` (interactive-only, in .zshrc) never runs. In interactive
# shells the activate hook later replaces shims with real install paths.
[[ -d "$HOME/.local/share/mise/shims" ]] && path=("$HOME/.local/share/mise/shims" $path)
export PATH

################################################################################
# Homelab tooling
################################################################################
# pvez anchors its project layout (config.yaml, apps/, state/, .build/) to its
# repo root. Setting it here lets the uv-tool-installed `pvez` run from any
# shell — interactive, non-interactive/agent, or cron — not just inside the
# repo. Guarded so hosts without this checkout fall back to pvez's own cwd +
# upward search instead of pinning a bad root.
[[ -d "${HOME}/dev/home/pvez" ]] && export PVEZ_ROOT="${HOME}/dev/home/pvez"

################################################################################
# Agent tooling
################################################################################
# Disable the codegraph MCP watchdog helper: it runs with cwd /tmp, which
# poisons herdr's foreground_cwd so new splits from agent panes open in /tmp
# instead of following the pane (herdr 0.7.4, new_cwd="follow"). The watchdog
# has never fired here (0 hits across 900+ codegraph session logs); worst case
# without it is a wedged codegraph MCP that needs a manual restart. In .zshenv
# (not .zprofile) so non-login herdr pane shells that launch agents get it.
export CODEGRAPH_NO_WATCHDOG=1
