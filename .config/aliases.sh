# Shared aliases (sourced from .zshrc; OS-specific aliases at the bottom)

# Dotfiles management (yadm)
compdef _git yadm
alias yst='yadm status'
alias ydi='yadm diff'
alias yadd='yadm add -u'
alias yco='yadm commit'

# Modern CLI replacements (only alias if the tool is installed)
command -v bat >/dev/null 2>&1 && alias cat='bat'
command -v lsd >/dev/null 2>&1 && alias ls='lsd'
command -v nvim >/dev/null 2>&1 && alias vim='nvim'

alias ff='fastfetch'
alias l2='ll --tree --depth 2'
alias glow='glow -p'
alias g='glow -p'
compdef _glow glow g
alias lf='leaf'
compdef _leaf leaf lf

alias dco='docker compose'

# Git shortcuts (hand-picked; the oh-my-zsh `git` plugin's ~190 g* aliases are
# intentionally disabled in .zshrc — most were foot-guns). Keep only these.
alias gs='git status'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gl='git log --oneline --decorate --graph'
alias gla='git log --graph --oneline --decorate --all'
alias gp='git push'
alias gpl='git pull'
alias ga='git add'

# Allow sudo to expand aliases that follow it
alias sudo='sudo '

# kubectl wrapper
if command -v kubecolor >/dev/null 2>&1; then
  alias ku='kubecolor'
  compdef _kubectl ku
fi

################################################################################
# Small helpers
################################################################################

# mkdir + cd in one step
mkcd() {
  if [[ -z "$1" ]]; then
    echo "usage: mkcd <dir>" >&2
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1"
}

# cd into a fresh throwaway directory
tmpd() {
  cd "$(mktemp -d)"
}

# snapshot a file before risky edits: foo.conf → foo.conf.bak.20260719
bak() {
  if [[ ! -e "$1" ]]; then
    echo "usage: bak <file>" >&2
    return 1
  fi
  cp -a -- "$1" "$1.bak.$(date +%Y%m%d)" && echo "→ $1.bak.$(date +%Y%m%d)"
}

# serve the cwd over HTTP (LAN sharing); optional port, default 8000
serve() {
  python3 -m http.server "${1:-8000}"
}

################################################################################
# memex — edge-hosted second brain (https://github.com/mjacobs/serverless-memex)
# Functions live in the project repo; sourced from there if checked out.
################################################################################
[[ -f "$HOME/dev/projects/serverless-memex/scripts/memex.sh" ]] &&
  source "$HOME/dev/projects/serverless-memex/scripts/memex.sh"

################################################################################
# kata — launch a Claude Code session tracked against a kata issue
# The repo's attention hooks (installed by `kata init --with-hooks`) read
# KATA_REF: SessionStart floors work.attention=ok, SessionEnd raises
# needs-human if the session ends without an explicit hand-off.
################################################################################
kwork() {
  if [[ -z "$1" ]]; then
    echo "usage: kwork <kata-ref> [claude args...]" >&2
    return 1
  fi
  local ref="$1"
  shift
  KATA_REF="$ref" claude "$@"
}

alias rr='roborev'
alias rt='roborev tui'
compdef _roborev rr

alias k='kata'

# Team projects are local federation spokes, so every routine command uses the
# same local daemon. Reuse kata's generated zsh completion for the short alias.
_kata_completion_alias() {
  case "${words[1]}" in
  k) words[1]=kata ;;
  esac
  _kata
}
compdef _kata kata
compdef _kata_completion_alias k

alias av=agentsview
compdef _agentsview av

# kwt worktree shortcuts
alias kt='kwt'
alias kls='kwt ls'
alias ksv="kwt ls -v"
alias klv='kwt ls -v'
alias kst='kwt status'
alias kcd='kwt cd'
alias ktui='kwt tui'
compdef _kwt kt kls ksv klv kst kcd ktui

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
