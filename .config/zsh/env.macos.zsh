################################################################################
# macOS environment (sourced from .zshenv)
################################################################################

# Homebrew (sets PATH, MANPATH, HOMEBREW_PREFIX, etc.)
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Java — prefer Homebrew openjdk if installed, else system Java
if [[ -d /opt/homebrew/opt/openjdk ]]; then
  export JAVA_HOME=/opt/homebrew/opt/openjdk
elif /usr/libexec/java_home -v 21 >/dev/null 2>&1; then
  export JAVA_HOME="$(/usr/libexec/java_home -v 21)"
fi

# Android SDK (standard macOS location)
[[ -d "$HOME/Library/Android/sdk" ]] && export ANDROID_HOME="$HOME/Library/Android/sdk"
