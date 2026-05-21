# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# User specific environment and startup programs
. "$HOME/.cargo/env"

export PATH="$HOME/.local/bin:$PATH:$HOME/.lmstudio/bin"

. "$HOME/.atuin/bin/env"
