# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . "$HOME/.bashrc"
fi

# User specific environment and startup programs
. "$HOME/.cargo/env"

export PATH="$HOME/.local/bin:$PATH:$HOME/.lmstudio/bin"


# Added by Antigravity CLI installer
export PATH="/home/mj/.local/bin:$PATH"
