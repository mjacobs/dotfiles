# ~/.profile - minimal login shell config
# LM Studio PATH is handled in ~/.zshenv; this file kept for POSIX shell compatibility.

# ~/.local/bin for POSIX shells (zsh gets it via .zshenv)
case ":$PATH:" in
*":$HOME/.local/bin:"*) ;;
*) export PATH="$HOME/.local/bin:$PATH" ;;
esac
