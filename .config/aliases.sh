# Shared aliases (sourced from .zshrc; OS-specific aliases at the bottom)

# Dotfiles management (yadm)
compdef _git yadm

# Modern CLI replacements (only alias if the tool is installed)
command -v bat >/dev/null 2>&1 && alias cat='bat'
command -v lsd >/dev/null 2>&1 && alias ls='lsd'
command -v nvim >/dev/null 2>&1 && alias vim='nvim'

alias ff='fastfetch'
alias l2='ll --tree --depth 2'
alias glow='glow -p'
alias g='glow -p'
compdef _glow glow g

alias dco='docker compose'

# Allow sudo to expand aliases that follow it
alias sudo='sudo '

# kubectl wrapper
if command -v kubecolor >/dev/null 2>&1; then
  alias k='kubecolor'
  compdef _kubectl k
fi

################################################################################
# memex — edge-hosted second brain (https://github.com/mjacobs/serverless-memex)
# Functions live in the project repo; sourced from there if checked out.
################################################################################
[[ -f "$HOME/dev/projects/serverless-memex/scripts/memex.sh" ]] &&
  source "$HOME/dev/projects/serverless-memex/scripts/memex.sh"

################################################################################
# OS-specific aliases
################################################################################
case "$OSTYPE" in
darwin*) [[ -f "${HOME}/.config/aliases.macos.sh" ]] && source "${HOME}/.config/aliases.macos.sh" ;;
linux*) [[ -f "${HOME}/.config/aliases.linux.sh" ]] && source "${HOME}/.config/aliases.linux.sh" ;;
esac

################################################################################
# Location-specific aliases (e.g. for work vs home)
################################################################################
[[ -s "$HOME/.config/aliases.local.sh" ]] && source "$HOME/.config/aliases.local.sh"
