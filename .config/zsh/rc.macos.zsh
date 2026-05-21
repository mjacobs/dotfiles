################################################################################
# macOS interactive rc (sourced from .zshrc before plugins load)
################################################################################

# fzf base — required by the oh-my-zsh fzf plugin
if [[ -n "$HOMEBREW_PREFIX" && -d "$HOMEBREW_PREFIX/opt/fzf" ]]; then
  export FZF_BASE="$HOMEBREW_PREFIX/opt/fzf"
elif [[ -d /opt/homebrew/opt/fzf ]]; then
  export FZF_BASE=/opt/homebrew/opt/fzf
fi

# oh-my-posh theme directory (theme filename is set in .zshrc)
export OMP_THEME_DIR="$HOME/Library/Application Support/omp-manager/themes"
