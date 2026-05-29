# Added by ForgeCode installer
export PATH="/home/mj/.local/bin:$PATH"
if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
  ;;
*) ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  # Load Carapace first so native and generated completions below can override it.
  if command -v carapace >/dev/null 2>&1; then
    export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
    source <(carapace _carapace bash)
  fi

  if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  elif [[ -r /etc/bash_completion ]]; then
    source /etc/bash_completion
  fi

  if [[ -r /home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh ]]; then
    source /home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh
  fi

  BASH_COMPLETION_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/bash/completions"
  if [[ -d "$BASH_COMPLETION_CACHE_DIR" ]]; then
    for completion_file in "$BASH_COMPLETION_CACHE_DIR"/*.bash; do
      [[ -r "$completion_file" ]] && source "$completion_file"
    done
    unset completion_file
  fi
fi
. "$HOME/.cargo/env"

PATH=/sbin:$HOME/.local/google-cloud-sdk/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:$HOME/.local/share/JetBrains/Toolbox/scripts:$HOME/.emacs.d/bin:$HOME/go/bin:/snap/bin

#eval "$(/bin/brew shellenv)"

# -f "$HOME/.shelloracle.bash" ] && source "$HOME/.shelloracle.bash"

# . "$HOME/.atuin/bin/env"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
# eval "$(atuin init bash)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

[[ -e "/home/mj/lib/oci_autocomplete.sh" ]] && source "/home/mj/lib/oci_autocomplete.sh"

################################################################################
# Completion diagnostics and fallback completions
################################################################################
compdebug() {
  local cmd="$1"

  if [[ -z "$cmd" ]]; then
    echo "usage: compdebug <command>"
    return 1
  fi

  echo "command:"
  type -a "$cmd"

  echo
  echo "bash completion:"
  complete -p "$cmd" 2>/dev/null || echo "No bash completion registered for $cmd"

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
