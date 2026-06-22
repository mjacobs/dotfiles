#!/usr/bin/env bash
# ai-usage.sh — compact cross-agent AI spend (today) for the oh-my-posh prompt.
#
# Data source: `agentsview usage statusline` (aggregates Claude Code, Codex,
# Gemini, Cursor, ...). Prints a short string like "󰚩 $53.11" (total) or
# "󰚩 cc $53.3 · gm $1.2" (per-agent, non-zero only). Prints nothing if there is
# no data, so the prompt segment hides itself.
#
# This is meant to be run by a throttled BACKGROUND refresher (see
# ~/.config/oh-my-posh/ai-usage.zsh); it never needs to be fast, but it is
# guarded with a timeout so it can never wedge.
#
# Usage: ai-usage.sh [total|split]   (default: total)
set -uo pipefail

mode="${1:-total}"
icon="${AI_USAGE_ICON:-󰚩}"   # nerd-font md-robot; override via $AI_USAGE_ICON

# Portable bounded run: prefer `timeout` (Linux), then `gtimeout` (macOS+coreutils),
# else run unbounded. Keeps the refresher from wedging without hard-depending on it.
if command -v timeout >/dev/null 2>&1; then _to() { timeout 8 "$@"; }
elif command -v gtimeout >/dev/null 2>&1; then _to() { gtimeout 8 "$@"; }
else _to() { "$@"; }; fi
av() { _to agentsview usage statusline --no-sync "$@" 2>/dev/null; }
# extract the dollar amount from "$53.11 today (claude)" -> "53.11"
num() { sed -nE 's/.*\$([0-9][0-9.]*).*/\1/p' <<<"${1:-}"; }

total="$(num "$(av)")"
[[ -z "$total" ]] && exit 0   # no data -> empty segment

if [[ "$mode" == "split" ]]; then
  out="$icon"; any=0
  for pair in claude:cc codex:cx gemini:gm; do
    a="${pair%%:*}"; lbl="${pair##*:}"
    v="$(num "$(av --agent "$a")")"
    if [[ -n "$v" && "$v" != "0" && "$v" != "0.00" ]]; then
      out+=" ${lbl} \$${v}"; any=1
    fi
  done
  [[ $any -eq 0 ]] && out="$icon \$$total"
  printf '%s' "$out"
else
  printf '%s $%s' "$icon" "$total"
fi
