# Added by ForgeCode installer
export PATH="/home/mj/.local/bin:$PATH"
if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
# </end ForgeCode installer additions>

export COLORTERM=truecolor

################################################################################
# zsh stuff
################################################################################

################################################################################
# OS-specific rc (sourced early so FZF_BASE, OMP_THEME_DIR, named dirs apply
# before plugins load)
################################################################################
case "$OSTYPE" in
darwin*) [[ -f "${HOME}/.config/zsh/rc.macos.zsh" ]] && source "${HOME}/.config/zsh/rc.macos.zsh" ;;
linux*) [[ -f "${HOME}/.config/zsh/rc.linux.zsh" ]] && source "${HOME}/.config/zsh/rc.linux.zsh" ;;
esac

################################################################################
# cached generated completions
################################################################################
# Keep fpath unique as completion dirs are prepended by shell config, plugins,
# Homebrew, and tool-specific setup snippets.
typeset -aU fpath

ZSH_COMPLETION_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
mkdir -p "$ZSH_COMPLETION_CACHE_DIR"

_zsh_completion_dirs=(
  "$ZSH_COMPLETION_CACHE_DIR"
  "$HOME/.zfunc"
  /home/linuxbrew/.linuxbrew/share/zsh-completions
  /home/linuxbrew/.linuxbrew/share/zsh/site-functions
  /usr/local/share/zsh/site-functions
  /usr/share/zsh/site-functions
  /usr/share/zsh/vendor-completions
)
_zsh_existing_fpath=("${fpath[@]}")
fpath=()
for dir in "${_zsh_completion_dirs[@]}"; do
  [[ -d "$dir" ]] && fpath+=("$dir")
done
fpath+=("${_zsh_existing_fpath[@]}")
unset dir _zsh_completion_dirs _zsh_existing_fpath

_zsh_comp_regen_needed=0
regen_zsh_completion_if_needed() {
  local cmd="$1"
  shift
  local -a gen=("$cmd")
  local outfile="$ZSH_COMPLETION_CACHE_DIR/_$cmd"
  local tmpfile

  if (($#)); then
    gen+=("$@")
  else
    gen+=(completion zsh)
  fi

  command -v "$cmd" >/dev/null 2>&1 || return 0

  # regenerate if missing, empty, or if the binary is newer than the cached completion
  if [[ ! -s "$outfile" || "$(command -v "$cmd")" -nt "$outfile" ]]; then
    tmpfile="${outfile}.$$.tmp"
    if "${gen[@]}" 2>/dev/null | sed '/./,$!d; s/`/\\`/g' >|"$tmpfile" && [[ -s "$tmpfile" ]]; then
      command mv -f "$tmpfile" "$outfile"
      _zsh_comp_regen_needed=1
    else
      command rm -f "$tmpfile"
    fi
  fi
}

# tools that support: <tool> completion zsh
regen_zsh_completion_if_needed bd
regen_zsh_completion_if_needed docker
regen_zsh_completion_if_needed kata
regen_zsh_completion_if_needed kubectl
regen_zsh_completion_if_needed mise
regen_zsh_completion_if_needed openclaw
regen_zsh_completion_if_needed tailscale

# regen_zsh_completion_if_needed helm
# regen_zsh_completion_if_needed kind
# regen_zsh_completion_if_needed task

# invalidate oh-my-zsh's compinit cache if any completions were regenerated
if ((_zsh_comp_regen_needed)); then
  command rm -f ~/.zcompdump*
fi
unset _zsh_comp_regen_needed

# oh-my-zsh installation path
export ZSH="${HOME}/.oh-my-zsh"

################################################################################
# zsh history
################################################################################
setopt no_flow_control

################################################################################
# fzf configuration (before plugins)
################################################################################
# Enhanced Ctrl+R history search
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window up:3:wrap --bind 'ctrl-/:toggle-preview' --border"
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border --bind 'ctrl-/:toggle-preview'"

################################################################################
# oh-my-zsh plugins
################################################################################

# pre-req:
#   git clone https://github.com/eliyastein/llm-zsh-plugin ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/llm

plugins=(
  fzf
  fzf-tab
  git
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-shift-select
  llm
)

# Oh My Zsh runs compinit during startup after adding plugin completion dirs to fpath.
# Do not add a separate compinit here unless intentionally overriding that behavior.
source "$ZSH/oh-my-zsh.sh"

# history-substring-search keybindings (must be after plugin load)
bindkey '^[[A' history-substring-search-up
bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OB' history-substring-search-down
[[ -n "$terminfo[kcuu1]" ]] && bindkey "$terminfo[kcuu1]" history-substring-search-up
[[ -n "$terminfo[kcud1]" ]] && bindkey "$terminfo[kcud1]" history-substring-search-down

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
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*:corrections' format '%F{yellow}-- %d (errors: %e) --%f'
[[ -n "$LS_COLORS" ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# More forgiving completion behavior
_comp_options+=(globdots)
setopt AUTO_MENU
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END

# fzf-tab enhancements - fuzzy file previews
zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --border
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || lsd -la --color=always $realpath 2>/dev/null || echo $word'

# Switch group with < and >
zstyle ':fzf-tab:*' switch-group '<' '>'

################################################################################
# Carapace fallback completions
################################################################################
if command -v carapace >/dev/null 2>&1; then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  source <(carapace _carapace zsh)

  # Carapace is broad by design; keep generated/native completions in front for
  # the tools this config explicitly caches.
  if (($+functions[compdef])); then
    _zsh_native_completion_pairs=(
      cargo:_cargo
      docker:_docker
      gh:_gh
      helm:_helm
      kind:_kind
      kubectl:_kubectl
      mise:_mise
      openclaw:_openclaw
      rustup:_rustup
      tailscale:_tailscale
      task:_task
      # Path-heavy commands: carapace 1.6.6+ double-escapes spaces in zsh
      # output, so restore native completion for the common file tools.
      cat:_cat
      ls:_ls
      cp:_cp
      mv:_mv
      rm:_rm
      ln:_ln
      mkdir:_mkdir
      rmdir:_rmdir
      touch:_touch
      chmod:_chmod
      chown:_chown
      stat:_stat
      head:_head
      tail:_tail
      less:_less
      vim:_vim
      vi:_vi
      find:_find
      tree:_tree
      tar:_tar
      zip:_zip
      gzip:_gzip
      grep:_grep
      du:_du
      wc:_wc
      diff:_diff
      sort:_sort
      uniq:_uniq
      open:_open
      jq:_jq
      xargs:_xargs
      readlink:_readlink
      basename:_basename
      rsync:_rsync
    )
    for pair in "${_zsh_native_completion_pairs[@]}"; do
      cmd="${pair%%:*}"
      comp="${pair#*:}"
      whence -w "$comp" >/dev/null 2>&1 && compdef "$comp" "$cmd"
    done
    # Tools without a native zsh completer: fall back to plain file completion
    # rather than carapace (still avoids the double-escape bug).
    _zsh_files_only_cmds=(
      nvim
      nano
      bat
      lsd
      rg
      fd
      more
      unzip
      gunzip
      xdg-open
      realpath
      dirname
    )
    for cmd in "${_zsh_files_only_cmds[@]}"; do
      compdef _files "$cmd"
    done
    unset cmd comp pair _zsh_native_completion_pairs _zsh_files_only_cmds
  fi
fi

compdebug() {
  local cmd="$1"

  if [[ -z "$cmd" ]]; then
    echo "usage: compdebug <command>"
    return 1
  fi

  echo "command:"
  whence -v "$cmd" || return 1

  echo
  echo "zsh completion function:"
  local comp="_$cmd"
  whence -v "$comp" || echo "No _$cmd found in fpath"

  echo
  echo "fpath entries containing possible completion:"
  local dir
  for dir in $fpath; do
    [[ -e "$dir/_$cmd" ]] && echo "$dir/_$cmd"
  done

  echo
  echo "carapace:"
  if command -v carapace >/dev/null 2>&1; then
    carapace "$cmd" --help >/dev/null 2>&1 &&
      echo "Carapace appears to know about $cmd" ||
      echo "No obvious Carapace completer for $cmd"
  else
    echo "carapace not installed"
  fi
}

################################################################################
# zsh-vim-mode
################################################################################
# esc-esc immediately switches to NORMAL mode
bindkey -rpM viins '^[^['

################################################################################
# GPG/SSH
################################################################################

# GPG (signing only, not used for SSH)
export GPG_TTY=$(tty)

# SSH agent - start one if not already running
if [[ -z "$SSH_AUTH_SOCK" || ! -S "$SSH_AUTH_SOCK" ]]; then
  eval "$(ssh-agent -s)" >/dev/null 2>&1
fi

################################################################################
# alias/fns
################################################################################
[[ -f "${HOME}/.config/aliases.sh" ]] && source "${HOME}/.config/aliases.sh"

################################################################################
# API Keys (loaded from ~/.secrets - not tracked in dotfiles repo)
################################################################################
[[ -f "${HOME}/.secrets" ]] && source "${HOME}/.secrets"

################################################################################
# local overrides
################################################################################
[[ -f "${HOME}/.zshrc.local" ]] && source "${HOME}/.zshrc.local"

# x-cmd - only source once (guarded to prevent duplicate loading)
[[ -z "$X_CMD_SOURCED" ]] && [[ -f "$HOME/.x-cmd.root/X" ]] && . "$HOME/.x-cmd.root/X" && export X_CMD_SOURCED=1

################################################################################
# prompt (oh-my-posh)
# OMP_THEME_DIR comes from the OS-specific rc sidecar; change the filename
# below to switch themes on all machines at once.
################################################################################
OMP_THEME_NAME="froczh.omp.json"
if command -v oh-my-posh >/dev/null 2>&1; then
  if [[ -n "$OMP_THEME_DIR" && -f "$OMP_THEME_DIR/$OMP_THEME_NAME" ]]; then
    eval "$(oh-my-posh init zsh --config "$OMP_THEME_DIR/$OMP_THEME_NAME")"
  else
    eval "$(oh-my-posh init zsh)"
  fi
fi

# GitHub CLI - load auth token into GH_TOKEN
if command -v gh >/dev/null 2>&1; then
  export GH_TOKEN="$(gh auth token 2>/dev/null)"
fi

# Mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# bun completions
[[ -s "$HOME/.oh-my-zsh/completions/_bun" ]] && source "$HOME/.oh-my-zsh/completions/_bun"

#compdef opencode
###-begin-opencode-completions-###
#
# yargs command completion script
#
# Installation: opencode completion >> ~/.zshrc
#    or opencode completion >> ~/.zprofile on OSX.
#
_opencode_yargs_completions() {
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT - 1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" opencode --get-yargs-completions "${words[@]}"))
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

# >>> forge initialize >>>
# !! Contents within this block are managed by 'forge zsh setup' !!
# !! Do not edit manually - changes will be overwritten !!

# Add required zsh plugins if not already present
if [[ ! " ${plugins[@]} " =~ " zsh-autosuggestions " ]]; then
  plugins+=(zsh-autosuggestions)
fi
if [[ ! " ${plugins[@]} " =~ " zsh-syntax-highlighting " ]]; then
  plugins+=(zsh-syntax-highlighting)
fi

# Load forge shell plugin (commands, completions, keybindings) if not already loaded
if [[ -z "$_FORGE_PLUGIN_LOADED" ]]; then
  eval "$(forge zsh plugin)"
fi

# Load forge shell theme (prompt with AI context) if not already loaded
if [[ -z "$_FORGE_THEME_LOADED" ]]; then
  eval "$(forge zsh theme)"
fi
# <<< forge initialize <<<

#####################################################################################
# atuin (disabled; unpleasant UX...)
#####################################################################################
# . "$HOME/.atuin/bin/env"
# eval "$(atuin init zsh)"
