# Linux-specific aliases (sourced from aliases.sh)

# Clipboard
alias c='wl-copy'
alias v='wl-paste'

# systemd
alias j='sudo journalctl'
alias s='sudo systemctl'
compdef _sudo j s

alias jcu='journalctl --user -b'
alias scu='systemctl --user'

# ZFS pool monitoring
alias zp='sudo zpool'
alias zpio='sudo zpool iostat -n 1 -v -q -l'
compdef _sudo zp zpio

# System monitoring (Linux-specific flags: sensors, diskio ramfs)
#command -v glances >/dev/null 2>&1 && \
#alias g='sudo glances -1 --enable-process-extended --diskio-show-ramfs --enable-plugin sensors'
alias bt='sudo btop'

# copy the absolute path of a file (or cwd) to the clipboard
cpath() {
  local p
  p="$(realpath -e -- "${1:-.}")" || return 1
  printf '%s' "$p" | wl-copy && echo "copied: $p"
}

# xdg-open, effortless: `xo` = open cwd in Dolphin, `xo file.pdf url…` = open
# each arg. Detached + silenced so GUI apps don't chatter or die with the shell.
xo() {
  [[ $# -eq 0 ]] && set -- .
  local t
  for t in "$@"; do
    setsid -f xdg-open "$t" >/dev/null 2>&1
  done
}

alias tgy='topgrade -y'
