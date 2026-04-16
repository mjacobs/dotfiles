#!/usr/bin/env bash
# Claude Code statusLine command
# Styled after the froczh oh-my-posh theme:
#   clock | date | path [git-branch +changes] | model ctx%

input=$(cat)

cwd=$(echo "$input"   | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# ---------------------------------------------------------------------------
# Working directory
# ---------------------------------------------------------------------------
dir="${cwd:-$(pwd)}"

# Replace $HOME prefix with ~, then build agnoster-style short path (max 3 parts)
home_prefix="$HOME"
if [[ "$dir" == "$home_prefix" ]]; then
  short_dir="~"
elif [[ "$dir" == "$home_prefix/"* ]]; then
  rel="${dir#$home_prefix/}"
  short_dir="~/$rel"
else
  short_dir="$dir"
fi

# Shorten to last 3 path components (agnoster_short style, max_depth 3)
IFS='/' read -ra parts <<< "$short_dir"
count="${#parts[@]}"
if (( count > 3 )); then
  short_dir="…/${parts[-3]}/${parts[-2]}/${parts[-1]}"
fi

# ---------------------------------------------------------------------------
# Git info (skip optional locks to avoid contention)
# ---------------------------------------------------------------------------
git_info=""
if GIT_OPTIONAL_LOCKS=0 git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" symbolic-ref --short HEAD 2>/dev/null \
           || GIT_OPTIONAL_LOCKS=0 git -C "$dir" rev-parse --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    # Count unstaged + staged changes
    unstaged=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    staged=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    changes=""
    (( unstaged > 0 )) && changes+=" ~${unstaged}"
    (( staged   > 0 )) && changes+=" +${staged}"
    git_info=$(printf '\033[0;36m\ue725 %s%s\033[0m' "$branch" "$changes")
  fi
fi

# ---------------------------------------------------------------------------
# Assemble segments — palette echoes the theme (cyan/blue path, yellow time)
# ---------------------------------------------------------------------------

# Time: clock + date (matches theme time segment)
time_part=$(printf '\033[0;33m\ue641 %s\033[0m \033[0;36m|\033[0m \033[0;33m\uf073 %s\033[0m' \
  "$(date +%H:%M:%S)" "$(date '+%d %b, %A')")

# Path: cyan-ish blue (matches theme #B6D6F2 foreground)
path_part=$(printf '\033[0;34m\uf07b %s\033[0m' "$short_dir")

# Build the main line: time | path [git]
line="${time_part}  ${path_part}"
[[ -n "$git_info" ]] && line+="  ${git_info}"

# Model + context usage (dimmed, appended at the right)
extras=""
[[ -n "$model"    ]] && extras="$model"
if [[ -n "$used_pct" ]]; then
  ctx=$(printf "ctx:%.0f%%" "$used_pct")
  extras="${extras:+$extras | }${ctx}"
fi
[[ -n "$extras" ]] && line+=$(printf '  \033[2m[%s]\033[0m' "$extras")

printf '%s' "$line"
