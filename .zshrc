################################################################################
# zsh stuff
################################################################################

################################################################################
# cached generated completions
################################################################################
ZSH_COMPLETION_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
mkdir -p "$ZSH_COMPLETION_CACHE_DIR"
fpath=("$ZSH_COMPLETION_CACHE_DIR" $fpath)

regen_zsh_completion_if_needed() {
  local cmd="$1"
  local outfile="$ZSH_COMPLETION_CACHE_DIR/_$cmd"

  command -v "$cmd" >/dev/null 2>&1 || return 0

  # regenerate if missing, or if the binary is newer than the cached completion
  if [[ ! -f "$outfile" || "$(command -v "$cmd")" -nt "$outfile" ]]; then
    "$cmd" completion zsh >|"$outfile"
  fi
}

# tools that support: <tool> completion zsh
regen_zsh_completion_if_needed kubectl
regen_zsh_completion_if_needed tailscale
# regen_zsh_completion_if_needed helm
# regen_zsh_completion_if_needed kind
# regen_zsh_completion_if_needed task

# oh-my-zsh installation path
export ZSH="${HOME}/.oh-my-zsh"

################################################################################
# zsh history
################################################################################
setopt no_flow_control
bindkey '^[[A' history-substring-search-up
bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OB' history-substring-search-down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

################################################################################
# fzf configuration (before plugins)
################################################################################
# Enhanced Ctrl+R history search
export FZF_BASE=/home/linuxbrew/.linuxbrew/opt/fzf/
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window up:3:wrap --bind 'ctrl-/:toggle-preview' --border"
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --bind 'ctrl-/:toggle-preview'"

################################################################################
# oh-my-zsh plugins
################################################################################

plugins=(
  fzf
  fzf-tab
  git
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

################################################################################
# Rust / rustup PATH precedence
################################################################################
# Ensure rustup-managed shims in ~/.cargo/bin take priority over distro /usr/bin
# for rustc/cargo/rust-analyzer, without removing Fedora packages.
# export PATH="$HOME/.cargo/bin:$PATH"

################################################################################
# Enhanced History Configuration
################################################################################
HISTSIZE=100000             # In-memory history (larger for better search)
SAVEHIST=100000             # On-disk history (match in-memory)
setopt INC_APPEND_HISTORY   # Write to history immediately, not on shell exit
setopt HIST_FIND_NO_DUPS    # Don't show duplicates when searching history
setopt HIST_REDUCE_BLANKS   # Remove extra whitespace from commands
setopt HIST_IGNORE_ALL_DUPS # Remove older duplicate when adding new entry

################################################################################
# Enhanced Completion Configuration
################################################################################
# Completion formatting and grouping
zstyle ':completion:*' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*:corrections' format '%F{yellow}-- %d (errors: %e) --%f'

# fzf-tab enhancements - fuzzy file previews
zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --border
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || lsd -la --color=always $realpath 2>/dev/null || echo $word'

# Switch group with < and >
zstyle ':fzf-tab:*' switch-group '<' '>'

compinit
setopt COMPLETE_ALIASES

################################################################################
# zsh-vim-mode
################################################################################
# esc-esc immediately switches to NORMAL mode
bindkey -rpM viins '^[^['

################################################################################
# Named Directories
################################################################################
hash -d srv=/mnt/data1/scratch

################################################################################
# GPG/SSH
################################################################################

# Use gpg-agent for both GPG and SSH
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
gpgconf --launch gpg-agent >/dev/null 2>&1
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1

################################################################################
# alias/fns
################################################################################
if [ -f "${HOME}/.config/aliases.sh" ]; then . "${HOME}/.config/aliases.sh"; fi

################################################################################
# golang
################################################################################
[[ -s "${HOME}/.gvm/scripts/gvm" ]] && source "${HOME}/.gvm/scripts/gvm"

################################################################################
# homebrew
################################################################################
[[ -f /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

################################################################################
# prompt (oh-my-posh)
################################################################################
if command -v oh-my-posh &>/dev/null; then
  #if [[  ]]; then
  #fi
fi

################################################################################
# API Keys (loaded from ~/.secrets - not tracked in dotfiles repo)
################################################################################
[[ -f "${HOME}/.secrets" ]] && source "${HOME}/.secrets"

# bun completions
#[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# x-cmd - only source once (guarded to prevent duplicate loading)
[[ -z "$X_CMD_SOURCED" ]] && [ -f "$HOME/.x-cmd.root/X" ] && . "$HOME/.x-cmd.root/X" && export X_CMD_SOURCED=1

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
eval "$(oh-my-posh init zsh --config '$HOME/.local/share/omp-manager/themes/froczh.omp.json')" # [omp-manager]
#compdef opencode
###-begin-opencode-completions-###
#
# yargs command completion script
#
# Installation: opencode completion >> ~/.zshrc
#    or opencode completion >> ~/.zprofile on OSX.
#
_opencode_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" opencode --get-yargs-completions "${words[@]}"))
  IFS=$si
  if [[ ${#reply} -gt 0 ]]; then
    _describe 'values' reply
  else
    _default
  fi
}
if [[ "'${zsh_eval_context[-1]}" == "loadautofunc" ]]; then
  _opencode_yargs_completions "$@"
else
  compdef _opencode_yargs_completions opencode
fi
###-end-opencode-completions-###

