# Linux-specific aliases (sourced from aliases.sh)

# Clipboard
alias c='wl-copy'
alias v='wl-paste'

alias sctlu='systemctl --user'

# systemd
alias j='sudo journalctl'
alias s='sudo systemctl'
compdef _sudo j s

# ZFS pool monitoring
alias zp='sudo zpool'
alias zpio='sudo zpool iostat -n 1 -v -q -l'
compdef _sudo zp zpio

# System monitoring (Linux-specific flags: sensors, diskio ramfs)
#command -v glances >/dev/null 2>&1 && \
#alias g='sudo glances -1 --enable-process-extended --diskio-show-ramfs --enable-plugin sensors'
