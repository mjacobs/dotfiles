# Linux-specific aliases (sourced from aliases.sh)

# Clipboard
alias c='xclip'
alias v='xclip -o'

# systemd
alias j='sudo journalctl'
alias s='sudo systemctl'
compdef _sudo j s

# ZFS pool monitoring
alias zs='sudo zpool iostat -n 1 -v -q -l'

# System monitoring (Linux-specific flags: sensors, diskio ramfs)
command -v glances >/dev/null 2>&1 && \
  alias g='sudo glances -1 --enable-process-extended --diskio-show-ramfs --enable-plugin sensors'
