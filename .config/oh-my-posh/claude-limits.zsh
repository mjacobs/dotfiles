#!/usr/bin/env zsh
# claude-limits.zsh — show Claude Code's 5h / weekly subscription usage windows
# in the prompt.
#
# Claude Code only exposes rate_limits to its statusLine command, only while a
# session is running. ~/.claude/statusline-command.sh writes a snapshot to a
# cache file; this hook reads it each prompt (pure zsh, no subprocess) and
# exports $CLAUDE_LIMITS for a text segment:
#     {{ if .Env.CLAUDE_LIMITS }} {{ .Env.CLAUDE_LIMITS }} {{ end }}
#
# Enable: add to ~/.zshrc →  source ~/.config/oh-my-posh/claude-limits.zsh
# The value reflects your last/active Claude Code session. Windows whose reset
# has already passed are dropped, and a snapshot older than ~8 days is ignored,
# so it self-clears rather than showing stale numbers forever.
#
# Tunables (set before sourcing): CLAUDE_LIMITS_CACHE, CLAUDE_LIMITS_ICON
# (set to "" to drop the icon), CLAUDE_LIMITS_RESET_GLYPH.
[[ -o interactive ]] || return 0

typeset -g CLAUDE_LIMITS_CACHE="${CLAUDE_LIMITS_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/omp/claude-limits}"
(( ${+CLAUDE_LIMITS_ICON} ))        || typeset -g CLAUDE_LIMITS_ICON=''        # nerd-font hourglass (U+F252)
(( ${+CLAUDE_LIMITS_RESET_GLYPH} )) || typeset -g CLAUDE_LIMITS_RESET_GLYPH='' # nerd-font refresh (U+F01E)

zmodload -F zsh/datetime +b:EPOCHSECONDS 2>/dev/null

_cl_reset() {   # REPLY := "2h13m" / "5d3h" / "47m" for epoch $1 vs now $2; empty if past/blank
  local t=$1 now=$2 d; REPLY=""
  [[ -n $t && $t != null ]] || return
  (( t > 0 )) || return
  (( d = t - now )); (( d <= 0 )) && return
  if   (( d >= 86400 )); then printf -v REPLY '%dd%dh' $((d/86400)) $(((d%86400)/3600))
  elif (( d >= 3600 ));  then printf -v REPLY '%dh%02dm' $((d/3600)) $(((d%3600)/60))
  else                        printf -v REPLY '%dm' $((d/60)); fi
}

_claude_limits_precmd() {
  emulate -L zsh
  export CLAUDE_LIMITS=""
  local f="$CLAUDE_LIMITS_CACHE"; [[ -r $f ]] || return
  local line="$(<$f)"; [[ -n $line ]] || return

  local -A d; local kv
  for kv in ${(s: :)line}; do d[${kv%%=*}]="${kv#*=}"; done

  local now=$EPOCHSECONDS ts=${d[ts]:-0}
  [[ $ts == <-> ]] || return
  (( now - ts < 8 * 86400 )) || return          # snapshot too old -> hide

  local -a parts; local REPLY s
  if [[ -n ${d[r5_pct]:-} ]]; then
    _cl_reset "${d[r5_reset]:-}" $now
    if [[ -n $REPLY || -z ${d[r5_reset]:-} || ${d[r5_reset]:-} == null ]]; then
      s="5h ${d[r5_pct]%%.*}%"; [[ -n $REPLY ]] && s+=" ${CLAUDE_LIMITS_RESET_GLYPH}$REPLY"
      parts+=$s
    fi
  fi
  if [[ -n ${d[r7_pct]:-} ]]; then
    _cl_reset "${d[r7_reset]:-}" $now
    if [[ -n $REPLY || -z ${d[r7_reset]:-} || ${d[r7_reset]:-} == null ]]; then
      parts+="7d ${d[r7_pct]%%.*}%"
    fi
  fi
  (( ${#parts} )) || return

  local out=""; [[ -n $CLAUDE_LIMITS_ICON ]] && out="${CLAUDE_LIMITS_ICON} "
  out+="${(j: · :)parts}"
  export CLAUDE_LIMITS="$out"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _claude_limits_precmd
