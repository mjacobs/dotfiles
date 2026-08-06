################################################################################
# Linux interactive rc (sourced from .zshrc before plugins load)
################################################################################

# fzf base — required by the oh-my-zsh fzf plugin (dnf fzf preferred, brew fallback)
if [[ -d /usr/share/fzf/shell ]]; then
  export FZF_BASE=/usr/share/fzf
elif [[ -d /home/linuxbrew/.linuxbrew/opt/fzf ]]; then
  export FZF_BASE=/home/linuxbrew/.linuxbrew/opt/fzf
fi

# Named directory for scratch storage
hash -d srv=/mnt/data1/scratch
