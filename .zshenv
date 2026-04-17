# Tie the PATH variable to the unique 'path' array
typeset -U path
path+=("${HOME}/.bun/bin")
path+=("${HOME}/.lmstudio/bin")
path+=("${HOME}/.local/bin")
path+=("${HOME}/.local/share/pnpm")

# Ensure the final PATH variable is exported for subprocesses
export PATH

# ripgrep config
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# pnpm needs this env var for global installs
export PNPM_HOME="${HOME}/.local/share/pnpm"

# cargo/rustup — prepends ~/.cargo/bin (takes priority over system rustc)
[[ -s "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

################################################################################
# nvm (exported for non-interactive shells; loaded lazily in .zshrc)
################################################################################
export NVM_DIR="$HOME/.nvm"

################################################################################
# OS-specific env (Homebrew, Java, Android, extra PATH entries)
################################################################################
case "$OSTYPE" in
  darwin*) [[ -f "${HOME}/.config/zsh/env.macos.zsh" ]] && source "${HOME}/.config/zsh/env.macos.zsh" ;;
  linux*)  [[ -f "${HOME}/.config/zsh/env.linux.zsh" ]] && source "${HOME}/.config/zsh/env.linux.zsh" ;;
esac
