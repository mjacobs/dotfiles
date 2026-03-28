# Dotfiles management (bare git repo)
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
compdef _git dotfiles

alias g="sudo glances -1 --enable-process-extended --diskio-show-ramfs --enable-plugin sensors"
alias zs="sudo zpool iostat -n 1 -v -q -l"

alias j="sudo journalctl"
alias s="sudo systemctl"
compdef _sudo j s

if [[ -f "/usr/bin/lsd" ]]; then
  alias ls="lsd"
fi

alias ff='fastfetch'

alias cat='bat'

alias vim='nvim'

#alias load-gvm='source "$HOME/.gvm/scripts/gvm"'

alias c="xclip"
alias v="xclip -o"

alias l2='ll --tree --depth 2'

alias glow="glow -p"

alias sudo='sudo '
alias k="kubecolor"
compdef _kubectl k
