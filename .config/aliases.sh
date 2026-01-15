# Dotfiles management (bare git repo)
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

alias g="sudo glances -1 --enable-process-extended --diskio-show-ramfs --enable-plugin sensors"
alias zs="sudo zpool iostat -n 1 -v -q -l"

alias j="sudo journalctl"
alias s="sudo systemctl"

if [[ -f "/usr/bin/lsd" ]]; then
  alias ls="lsd"
fi

alias ff='fastfetch'

alias cat='bat'
[[ -f /home/linuxbrew/.linuxbrew/bin/mcat ]] && alias mcat='/home/linuxbrew/.linuxbrew/bin/mcat'

alias vim='nvim'

#alias load-gvm='source "$HOME/.gvm/scripts/gvm"'

alias c="xclip"
alias v="xclip -o"

alias codex='open-codex'
#alias claude="$HOME/.claude/local/claude"

alias cx='open-codex'
alias l2='ll --tree --depth 2'

alias catt="glow"
alias catp="glow -p"
[[ -f "$HOME/dev/private/rp/SillyTavern/start.sh" ]] && alias st="$HOME/dev/private/rp/SillyTavern/start.sh"
