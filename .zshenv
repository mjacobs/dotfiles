# Tie the PATH variable to the unique 'path' array
typeset -U path
path+=("${HOME}/.bun/bin")
path+=("${HOME}/.lmstudio/bin")
path+=("${HOME}/.local/bin")
path+=("${HOME}/.local/share/pnpm")
path+=("${HOME}/.local/google-cloud-sdk/bin")
path+=("${HOME}/.local/share/JetBrains/Toolbox/scripts")
path+=("/home/linuxbrew/.linuxbrew/bin")
path+=("/home/linuxbrew/.linuxbrew/sbin")
path+=('/usr/local/cuda/bin')
#path+=("${HOME}/.pixi/bin")

# Ensure the final PATH variable is exported for subprocesses
export PATH

# ripgrep config
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# pnpm needs this env var for global installs
export PNPM_HOME="${HOME}/.local/share/pnpm"

# cargo/rustup — prepends ~/.cargo/bin (takes priority over system rustc)
. "$HOME/.cargo/env"

################################################################################
# Android / Java (for React Native / Expo builds)
################################################################################
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export ANDROID_HOME="$HOME/.local/Android"

################################################################################
# nvm (exported for non-interactive shells; loaded lazily in .zshrc)
################################################################################
export NVM_DIR="$HOME/.nvm"
