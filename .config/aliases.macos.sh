# macOS-specific aliases (sourced from aliases.sh)

# Clipboard
alias c='pbcopy'
alias v='pbpaste'

# System monitoring
command -v glances >/dev/null 2>&1 && alias g='sudo glances -1 --enable-process-extended'
