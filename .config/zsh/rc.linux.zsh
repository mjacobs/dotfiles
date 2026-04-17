################################################################################
# Linux interactive rc (sourced from .zshrc before plugins load)
################################################################################

# fzf base — required by the oh-my-zsh fzf plugin
[[ -d /home/linuxbrew/.linuxbrew/opt/fzf ]] && export FZF_BASE=/home/linuxbrew/.linuxbrew/opt/fzf

# Named directory for scratch storage
hash -d srv=/mnt/data1/scratch

# oh-my-posh theme directory (theme filename is set in .zshrc)
export OMP_THEME_DIR="$HOME/.local/share/omp-manager/themes"
