#!/usr/bin/env bash
# Claude Code statusLine command
# Powerline-style rainbow segments: time | date | path | git | model | ctx
# Compatible with bash 3.2 (macOS) and bash 4+ (Linux).

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# ---------------------------------------------------------------------------
# Glyphs (Nerd Font + Unicode) as UTF-8 byte literals — bash 3.2 safe
# ---------------------------------------------------------------------------
GLYPH_CLOCK=$'\xee\x99\x81'    #
GLYPH_CAL=$'\xef\x81\xb3'      #
GLYPH_FOLDER=$'\xef\x81\xbb'   #
GLYPH_BRANCH=$'\xee\x9c\xa5'   #
SEP=$'\xee\x82\xb0'            #  powerline right-arrow
ELLIPSIS=$'\xe2\x80\xa6'       # …

# ---------------------------------------------------------------------------
# Working directory
# ---------------------------------------------------------------------------
dir="${cwd:-$(pwd)}"

home_prefix="$HOME"
if [[ "$dir" == "$home_prefix" ]]; then
  short_dir="~"
elif [[ "$dir" == "$home_prefix/"* ]]; then
  short_dir="~/${dir#$home_prefix/}"
else
  short_dir="$dir"
fi

# Shorten to last 3 path components (bash 3.2-compatible indexing)
IFS='/' read -ra parts <<<"$short_dir"
count="${#parts[@]}"
if ((count > 3)); then
  short_dir="${ELLIPSIS}/${parts[count-3]}/${parts[count-2]}/${parts[count-1]}"
fi

# ---------------------------------------------------------------------------
# Git info
# ---------------------------------------------------------------------------
branch=""
git_changes=""
git_dirty=0
if GIT_OPTIONAL_LOCKS=0 git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" symbolic-ref --short HEAD 2>/dev/null ||
    GIT_OPTIONAL_LOCKS=0 git -C "$dir" rev-parse --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    unstaged=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    staged=$(GIT_OPTIONAL_LOCKS=0 git -C "$dir" diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    ((unstaged > 0)) && { git_changes+=" ~${unstaged}"; git_dirty=1; }
    ((staged > 0))   && { git_changes+=" +${staged}"; git_dirty=1; }
  fi
fi

# ---------------------------------------------------------------------------
# Palette (256-color, Catppuccin-mocha inspired). Dark fg on bright bg.
# ---------------------------------------------------------------------------
FG_DARK=235
TIME_BG=221       # yellow
DATE_BG=215       # peach
PATH_BG=75        # blue
GIT_CLEAN_BG=114  # green
GIT_DIRTY_BG=174  # rose
MODEL_BG=141      # mauve
CTX_BG=117        # sky

esc=$'\033'
reset="${esc}[0m"

# Build segment list: parallel arrays of bg + text
segs_bg=()
segs_text=()

segs_bg+=("$TIME_BG");   segs_text+=("${GLYPH_CLOCK} $(date +%H:%M:%S)")
segs_bg+=("$DATE_BG");   segs_text+=("${GLYPH_CAL} $(date '+%d %b, %a')")
segs_bg+=("$PATH_BG");   segs_text+=("${GLYPH_FOLDER} ${short_dir}")

if [[ -n "$branch" ]]; then
  if ((git_dirty)); then
    segs_bg+=("$GIT_DIRTY_BG")
  else
    segs_bg+=("$GIT_CLEAN_BG")
  fi
  segs_text+=("${GLYPH_BRANCH} ${branch}${git_changes}")
fi

[[ -n "$model" ]] && { segs_bg+=("$MODEL_BG"); segs_text+=("$model"); }
if [[ -n "$used_pct" ]]; then
  segs_bg+=("$CTX_BG")
  segs_text+=("$(printf 'ctx %.0f%%' "$used_pct")")
fi

# Render with powerline arrows between segments and a closing cap.
n=${#segs_bg[@]}
out=""
for ((i = 0; i < n; i++)); do
  bg="${segs_bg[i]}"
  text="${segs_text[i]}"
  out+="${esc}[38;5;${FG_DARK};48;5;${bg}m ${text} "
  if ((i + 1 < n)); then
    next="${segs_bg[i+1]}"
    out+="${esc}[38;5;${bg};48;5;${next}m${SEP}"
  else
    out+="${esc}[0;38;5;${bg}m${SEP}${reset}"
  fi
done

printf '%s' "$out"
