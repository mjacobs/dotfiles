# Tie the PATH variable to the unique 'path' array
typeset -U path
path+=("${HOME}/.bun/bin")
path+=("${HOME}/.cargo/bin")
path+=("${HOME}/.lmstudio/bin")
path+=("${HOME}/.local/bin")
path+=("${HOME}/.local/share/pnpm")
path+=("${HOME}/.local/google-cloud-sdk/bin")
path+=("${HOME}/.local/share/JetBrains/Toolbox/scripts")
path+=("/home/linuxbrew/.linuxbrew/bin")
path+=("/home/linuxbrew/.linuxbrew/sbin")
path+=("/home/linuxbrew/.linuxbrew/opt/fzf/bin")
path+=('/usr/local/cuda/bin')
#path+=("${HOME}/.pixi/bin")

# Ensure the final PATH variable is exported for subprocesses
export PATH

. "$HOME/.cargo/env"

################################################################################
# Android / Java (for React Native / Expo builds)
################################################################################
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export ANDROID_HOME="$HOME/.local/Android"

################################################################################
# node / npm / nvm
################################################################################
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
