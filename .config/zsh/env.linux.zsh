################################################################################
# Linux environment (sourced from .zshenv)
################################################################################

# Homebrew (Linux)
[[ -x /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Additional Linux PATH entries
typeset -U path
path+=("${HOME}/.local/google-cloud-sdk/bin")
path+=("${HOME}/.local/share/JetBrains/Toolbox/scripts")
path+=('/usr/local/cuda/bin')
export PATH

# Java / Android for React Native / Expo
[[ -d /usr/lib/jvm/java-21-openjdk ]] && export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
[[ -d "$HOME/.local/Android" ]] && export ANDROID_HOME="$HOME/.local/Android"
