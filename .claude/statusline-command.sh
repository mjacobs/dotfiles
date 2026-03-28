#!/usr/bin/env bash
# Claude Code statusLine command
# Mirrors the bash PS1: bold-green user@host, colon, bold-blue cwd
# Plus Claude Code context: model and context window usage

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Bold green for user@host
user_host=$(printf '\033[01;32m%s@%s\033[00m' "$(whoami)" "$(hostname -s)")

# Bold blue for cwd (use cwd from Claude if available, else pwd)
if [[ -n "$cwd" ]]; then
  dir="$cwd"
else
  dir="$(pwd)"
fi
dir_part=$(printf '\033[01;34m%s\033[00m' "$dir")

# Assemble prompt-style prefix
prompt_part="${user_host}:${dir_part}"

# Append model name if available
extras=""
if [[ -n "$model" ]]; then
  extras="$model"
fi

# Append context usage if available
if [[ -n "$used_pct" ]]; then
  ctx=$(printf "ctx:%.0f%%" "$used_pct")
  if [[ -n "$extras" ]]; then
    extras="$extras | $ctx"
  else
    extras="$ctx"
  fi
fi

if [[ -n "$extras" ]]; then
  printf '%s  \033[2m[%s]\033[0m' "$prompt_part" "$extras"
else
  printf '%s' "$prompt_part"
fi
