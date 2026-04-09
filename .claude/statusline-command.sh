#!/usr/bin/env bash
# Claude Code statusLine command
# Shows: user@host  cwd  [git-branch]  model | ctx%

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Resolve working directory
if [[ -n "$cwd" ]]; then
  dir="$cwd"
else
  dir="$(pwd)"
fi

# Shorten home prefix to ~
home_prefix="$HOME"
if [[ "$dir" == "$home_prefix" ]]; then
  short_dir="~"
elif [[ "$dir" == "$home_prefix/"* ]]; then
  short_dir="~${dir#$home_prefix}"
else
  short_dir="$dir"
fi

# Bold green: user@host
user_host=$(printf '\033[01;32m%s@%s\033[00m' "$(whoami)" "$(hostname -s)")

# Bold blue: directory
dir_part=$(printf '\033[01;34m%s\033[00m' "$short_dir")

# Git branch (skip locks to avoid contention)
git_branch=""
if git --git-dir="$dir/.git" rev-parse --is-inside-work-tree >/dev/null 2>&1 || \
   git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" symbolic-ref --short HEAD 2>/dev/null \
           || GIT_OPTIONAL_LOCKS=0 git -C "$dir" rev-parse --short HEAD 2>/dev/null)
  [[ -n "$branch" ]] && git_branch=$(printf ' \033[01;33m(%s)\033[00m' "$branch")
fi

# Assemble left side
left="${user_host}:${dir_part}${git_branch}"

# Right side: model and context usage
extras=""
if [[ -n "$model" ]]; then
  extras="$model"
fi
if [[ -n "$used_pct" ]]; then
  ctx=$(printf "ctx:%.0f%%" "$used_pct")
  if [[ -n "$extras" ]]; then
    extras="$extras | $ctx"
  else
    extras="$ctx"
  fi
fi

if [[ -n "$extras" ]]; then
  printf '%s  \033[2m[%s]\033[0m' "$left" "$extras"
else
  printf '%s' "$left"
fi
