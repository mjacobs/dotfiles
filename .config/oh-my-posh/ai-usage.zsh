#!/usr/bin/env zsh
# ai-usage.zsh — feed today's cross-agent AI spend to the oh-my-posh prompt.
#
# How it works (zero prompt latency by design):
#   * precmd exports $AI_USAGE by reading a small cache file (instant).
#   * the cache is refreshed by a DETACHED background job, at most once every
#     $AI_USAGE_TTL seconds, so `agentsview` never runs on the prompt path.
#   * the theme shows it via a text segment: {{ if .Env.AI_USAGE }}...{{ end }}
#
# Enable by adding to ~/.zshrc:   source ~/.config/oh-my-posh/ai-usage.zsh
# Tune via env before sourcing:   AI_USAGE_TTL=120  AI_USAGE_MODE=total|split
#
# Only meaningful in interactive shells.
[[ -o interactive ]] || return 0

# Self-disable cleanly when the data source isn't installed, so this file is safe
# to source on any machine (the prompt's AI segment then just stays hidden).
typeset -g AI_USAGE_REQUIRE="${AI_USAGE_REQUIRE:-agentsview}"
command -v "$AI_USAGE_REQUIRE" >/dev/null 2>&1 || return 0

typeset -g AI_USAGE_CACHE="${AI_USAGE_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/omp/ai-usage}"
typeset -g AI_USAGE_TTL="${AI_USAGE_TTL:-120}"          # seconds between refreshes
typeset -g AI_USAGE_MODE="${AI_USAGE_MODE:-total}"      # total | split
typeset -g _AI_USAGE_SCRIPT="${HOME}/.config/oh-my-posh/scripts/ai-usage.sh"

# Needed for fast mtime math without spawning `date`/`stat`.
zmodload -F zsh/datetime +b:EPOCHSECONDS 2>/dev/null
zmodload -F zsh/stat +b:zstat 2>/dev/null

_ai_usage_refresh() {
  emulate -L zsh
  [[ -x "$_AI_USAGE_SCRIPT" ]] || return 0
  local f="$AI_USAGE_CACHE"
  mkdir -p "${f:h}" 2>/dev/null
  if [[ -f "$f" ]]; then
    local mtime; zstat -A mtime +mtime -- "$f" 2>/dev/null
    (( ${mtime:-0} && EPOCHSECONDS - mtime < AI_USAGE_TTL )) && return 0
  fi
  touch "$f" 2>/dev/null   # claim the slot so concurrent shells don't stampede
  ( "$_AI_USAGE_SCRIPT" "$AI_USAGE_MODE" >| "$f.tmp" 2>/dev/null && mv -f "$f.tmp" "$f" 2>/dev/null ) &!
}

_ai_usage_precmd() {
  if [[ -r "$AI_USAGE_CACHE" ]]; then
    export AI_USAGE="$(<"$AI_USAGE_CACHE")"
  else
    export AI_USAGE=""
  fi
  _ai_usage_refresh
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _ai_usage_precmd
