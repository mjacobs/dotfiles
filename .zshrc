################################################################################
# zsh stuff
################################################################################

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

autoload -U compinit && compinit

################################################################################
# fzf configuration
################################################################################
# if [[ $TERM_PROGRAM == "WarpTerminal" ]]; then
#   export FZF_TMUX=0
#   export FZF_DEFAULT_OPTS="--no-clear"
# fi

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
  eval "$(oh-my-posh init zsh --config ${HOME}/dev/productivity/oh-my-posh/themes/kushal.omp.json)"
fi


################################################################################
# API Keys (loaded from ~/.secrets - not tracked in dotfiles repo)
################################################################################
[[ -f "${HOME}/.secrets" ]] && source "${HOME}/.secrets"

# bun completions
#[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


[ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
