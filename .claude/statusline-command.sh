#!/usr/bin/env bash
# Claude Code statusLine command
# Tokyo Night powerline (24-bit color). Segments (each shown only when data exists):
#   vim mode | time | date | repo+branch | path | model+thinking |
#   effort | context-bar | rate-limits | cost
# Dynamic colors: vim mode, git dirty state, effort level, and the
# context/rate-limit severity bars all change hue based on their value.
# Compatible with bash 3.2 (macOS) and bash 4+ (Linux).

input=$(cat)

# --- One jq pass: pull everything into tab-separated fields -----------------
parse=$(echo "$input" | jq -r '
  [ (.workspace.current_dir // .cwd // ""),
    (.model.display_name // ""),
    (.context_window.used_percentage // ""),
    (.workspace.repo.owner // ""),
    (.workspace.repo.name // ""),
    (.effort.level // ""),
    (.thinking.enabled // false),
    (.vim.mode // ""),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.five_hour.resets_at // ""),
    (.rate_limits.seven_day.used_percentage // ""),
    (.rate_limits.seven_day.resets_at // ""),
    (.cost.total_cost_usd // ""),
    (.cost.total_lines_added // ""),
    (.cost.total_lines_removed // ""),
    (.workspace.git_worktree // "")
  ] | map(tostring) | join("")')
# Unit-separator (0x1f) delimiter: non-whitespace, so empty fields are
# preserved instead of collapsing the way tab/space would under `read`.
IFS=$'\x1f' read -r cwd model used_pct repo_owner repo_name effort thinking \
  vim_mode r5_pct r5_reset r7_pct r7_reset cost lines_add lines_del worktree \
  <<<"$parse"

# --- Bridge to the shell prompt (oh-my-posh) -------------------------------
# The shell prompt can't see this stdin JSON, so publish the 5h/7d rate-limit
# windows to a cache file a prompt segment can read (see
# ~/.config/oh-my-posh/claude-limits.zsh). Values + reset epochs only; no
# secrets. Best-effort; never affects footer rendering.
if [[ -n "$r5_pct" || -n "$r7_pct" ]]; then
  _omp_dir="${XDG_CACHE_HOME:-$HOME/.cache}/omp"
  mkdir -p "$_omp_dir" 2>/dev/null &&
    printf 'ts=%s r5_pct=%s r5_reset=%s r7_pct=%s r7_reset=%s\n' \
      "$(date +%s)" "$r5_pct" "$r5_reset" "$r7_pct" "$r7_reset" \
      >"$_omp_dir/claude-limits" 2>/dev/null
  unset _omp_dir
fi

# ---------------------------------------------------------------------------
# Glyphs (Nerd Font + Unicode) as UTF-8 byte literals — bash 3.2 safe
# ---------------------------------------------------------------------------
GLYPH_CLOCK=$'\xee\x99\x81'  #
GLYPH_CAL=$'\xef\x81\xb3'    #
GLYPH_FOLDER=$'\xef\x81\xbb' #
GLYPH_BRANCH=$'\xee\x9c\xa5' #
GLYPH_REPO=$'\xef\x82\x9b'   #  (github)
# NOTE: use Nerd Fonts v3 codepoints. The old v2 md-* range (U+F500-F8FF) was
# remapped in v3, so v2 values now fall through to whatever font claims that
# private-use slot (Jomolhari, i.e. Tibetan letters, on this box).
GLYPH_ROBOT=$'\xf3\xb0\x9a\xa9' # 󰚩 (md-robot, U+F06A9)
GLYPH_BRAIN=$'\xf3\xb0\xa7\x91' # 󰧑 (md-brain, U+F09D1)
GLYPH_BOLT=$'\xef\x83\xa7'      #  (effort)
GLYPH_GAUGE=$'\xef\x83\xa4'     #  (context)
GLYPH_HOURGLASS=$'\xef\x89\x92' #  (rate limits)
GLYPH_VIM=$'\xee\x98\xab'       #  (vim)
GLYPH_DOLLAR=$'\xef\x85\x95'    #  (cost)
GLYPH_RESET=$'\xef\x80\x9e'     #  (refresh / resets-in)
SEP=$'\xee\x82\xb0'             #  powerline right-arrow (between colors)
SEP_THIN=$'\xee\x82\xb1'        #  thin separator (same-color segments)
ELLIPSIS=$'\xe2\x80\xa6'        # …

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
to_int() { printf '%.0f' "${1:-0}" 2>/dev/null || echo 0; }

# --- Tokyo Night palette, as 24-bit "r;g;b" fragments -----------------------
TN_BG='26;27;38'         # #1a1b26  base (segment text on colored fills)
TN_FG='192;202;245'      # #c0caf5  foreground (text on dark fills)
TN_BLUE='122;162;247'    # #7aa2f7
TN_CYAN='125;207;255'    # #7dcfff
TN_TEAL='115;218;202'    # #73daca
TN_GREEN='158;206;106'   # #9ece6a
TN_YELLOW='224;175;104'  # #e0af68
TN_ORANGE='255;158;100'  # #ff9e64
TN_RED='247;118;142'     # #f7768e
TN_MAGENTA='187;154;247' # #bb9af7
TN_PURPLE='157;124;216'  # #9d7cd8
TN_GREY='65;72;104'      # #414868  terminal black
TN_SLATE='86;95;137'     # #565f89  comment

# Severity color from a 0-100 percentage: green -> yellow -> orange -> red
sev_color() {
  local p
  p=$(to_int "$1")
  if ((p < 50)); then
    echo "$TN_GREEN"
  elif ((p < 75)); then
    echo "$TN_YELLOW"
  elif ((p < 90)); then
    echo "$TN_ORANGE"
  else
    echo "$TN_RED"
  fi
}

# Effort level -> color
effort_color() {
  case "$1" in
  low) echo "$TN_SLATE" ;;
  medium) echo "$TN_CYAN" ;;
  high) echo "$TN_YELLOW" ;;
  xhigh) echo "$TN_ORANGE" ;;
  max) echo "$TN_RED" ;;
  *) echo "$TN_MAGENTA" ;;
  esac
}

# Vim mode -> color
vim_color() {
  case "$1" in
  NORMAL) echo "$TN_BLUE" ;;
  INSERT) echo "$TN_GREEN" ;;
  VISUAL*) echo "$TN_ORANGE" ;;
  REPLACE) echo "$TN_RED" ;;
  *) echo "$TN_SLATE" ;;
  esac
}

# Readable text color for a given fill: light on the two dark fills, dark
# everywhere else.
fg_for() {
  case "$1" in
  "$TN_GREY" | "$TN_SLATE") echo "$TN_FG" ;;
  *) echo "$TN_BG" ;;
  esac
}

# 5-cell block bar from a 0-100 percentage
make_bar() {
  local p filled i out=""
  p=$(to_int "$1")
  filled=$(((p + 10) / 20))
  ((filled > 5)) && filled=5
  ((filled < 0)) && filled=0
  for ((i = 0; i < 5; i++)); do
    if ((i < filled)); then out+=$'\xe2\x96\x88'; else out+=$'\xe2\x96\x91'; fi # █ / ░
  done
  printf '%s' "$out"
}

# Epoch seconds -> "2h13m" / "47m" until reset
fmt_reset() {
  local target now diff h m
  target=$(to_int "$1")
  now=$(date +%s)
  diff=$((target - now))
  ((diff < 0)) && diff=0
  h=$((diff / 3600))
  m=$(((diff % 3600) / 60))
  if ((h > 0)); then printf '%dh%02dm' "$h" "$m"; else printf '%dm' "$m"; fi
}

# ---------------------------------------------------------------------------
# Working directory (shorten to last 3 components, ~ for home)
# ---------------------------------------------------------------------------
dir="${cwd:-$(pwd)}"
if [[ "$dir" == "$HOME" ]]; then
  short_dir="~"
elif [[ "$dir" == "$HOME/"* ]]; then
  short_dir="~/${dir#$HOME/}"
else
  short_dir="$dir"
fi
IFS='/' read -ra parts <<<"$short_dir"
count="${#parts[@]}"
if ((count > 3)); then
  short_dir="${ELLIPSIS}/${parts[count - 3]}/${parts[count - 2]}/${parts[count - 1]}"
fi

# ---------------------------------------------------------------------------
# Git branch + dirty state
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
    ((unstaged > 0)) && {
      git_changes+=" ~${unstaged}"
      git_dirty=1
    }
    ((staged > 0)) && {
      git_changes+=" +${staged}"
      git_dirty=1
    }
  fi
fi

# ---------------------------------------------------------------------------
# Segment assignments
# ---------------------------------------------------------------------------
CLOCK_BG="$TN_MAGENTA"
DATE_BG="$TN_PURPLE"
GIT_CLEAN_BG="$TN_GREEN"
GIT_DIRTY_BG="$TN_YELLOW"
PATH_BG="$TN_BLUE"
MODEL_BG="$TN_CYAN"
COST_BG="$TN_GREY"

esc=$'\033'
reset="${esc}[0m"

segs_bg=()
segs_text=()

# --- vim mode (only when vim enabled) --------------------------------------
if [[ -n "$vim_mode" ]]; then
  segs_bg+=("$(vim_color "$vim_mode")")
  segs_text+=("${GLYPH_VIM} ${vim_mode}")
fi

# --- clock / date ----------------------------------------------------------
segs_bg+=("$CLOCK_BG")
segs_text+=("${GLYPH_CLOCK} $(date +%H:%M)")
segs_bg+=("$DATE_BG")
segs_text+=("${GLYPH_CAL} $(date '+%d %b, %a')")

# --- repo + branch ---------------------------------------------------------
repo_label=""
[[ -n "$repo_name" ]] && repo_label="${GLYPH_REPO} ${repo_owner:+$repo_owner/}${repo_name}"
if [[ -n "$worktree" ]]; then
  branch_disp="$branch (${worktree})"
else
  branch_disp="$branch"
fi
git_seg=""
[[ -n "$repo_label" ]] && git_seg="$repo_label"
if [[ -n "$branch" ]]; then
  [[ -n "$git_seg" ]] && git_seg+="  "
  git_seg+="${GLYPH_BRANCH} ${branch_disp}${git_changes}"
fi
if [[ -n "$git_seg" ]]; then
  if ((git_dirty)); then segs_bg+=("$GIT_DIRTY_BG"); else segs_bg+=("$GIT_CLEAN_BG"); fi
  segs_text+=("$git_seg")
fi

# --- path ------------------------------------------------------------------
segs_bg+=("$PATH_BG")
segs_text+=("${GLYPH_FOLDER} ${short_dir}")

# --- model (+ thinking) ----------------------------------------------------
if [[ -n "$model" ]]; then
  model_text="${GLYPH_ROBOT} ${model}"
  [[ "$thinking" == "true" ]] && model_text+=" ${GLYPH_BRAIN}"
  segs_bg+=("$MODEL_BG")
  segs_text+=("$model_text")
fi

# --- effort level ----------------------------------------------------------
if [[ -n "$effort" ]]; then
  segs_bg+=("$(effort_color "$effort")")
  segs_text+=("${GLYPH_BOLT} ${effort}")
fi

# --- context window --------------------------------------------------------
if [[ -n "$used_pct" ]]; then
  ctx_int=$(to_int "$used_pct")
  segs_bg+=("$(sev_color "$ctx_int")")
  segs_text+=("${GLYPH_GAUGE} $(make_bar "$ctx_int") ${ctx_int}%")
fi

# --- rate limits (5h / 7d) -------------------------------------------------
if [[ -n "$r5_pct" || -n "$r7_pct" ]]; then
  r5i=$(to_int "$r5_pct")
  r7i=$(to_int "$r7_pct")
  worst=$r5i
  ((r7i > worst)) && worst=$r7i
  rl_text="${GLYPH_HOURGLASS}"
  [[ -n "$r5_pct" ]] && rl_text+=" 5h ${r5i}%"
  [[ -n "$r7_pct" ]] && rl_text+=" 7d ${r7i}%"
  if [[ -n "$r5_reset" ]]; then
    rl_text+=" ${GLYPH_RESET}$(fmt_reset "$r5_reset")"
  elif [[ -n "$r7_reset" ]]; then
    rl_text+=" ${GLYPH_RESET}$(fmt_reset "$r7_reset")"
  fi
  segs_bg+=("$(sev_color "$worst")")
  segs_text+=("$rl_text")
fi

# --- cost + lines changed --------------------------------------------------
if [[ -n "$cost" ]]; then
  cost_text="$(printf '%s$%.2f' "$GLYPH_DOLLAR" "$cost")"
  if [[ -n "$lines_add" || -n "$lines_del" ]]; then
    cost_text+=" +${lines_add:-0}/-${lines_del:-0}"
  fi
  segs_bg+=("$COST_BG")
  segs_text+=("$cost_text")
fi

# ---------------------------------------------------------------------------
# Render: powerline arrows between segments + closing cap
# ---------------------------------------------------------------------------
n=${#segs_bg[@]}
out=""
for ((i = 0; i < n; i++)); do
  bg="${segs_bg[i]}"
  text="${segs_text[i]}"
  fg=$(fg_for "$bg")
  out+="${esc}[38;2;${fg};48;2;${bg}m ${text} "
  if ((i + 1 < n)); then
    next="${segs_bg[i + 1]}"
    if [[ "$bg" == "$next" ]]; then
      out+="${esc}[38;2;${fg};48;2;${bg}m${SEP_THIN}"
    else
      out+="${esc}[38;2;${bg};48;2;${next}m${SEP}"
    fi
  else
    out+="${esc}[0;38;2;${bg}m${SEP}${reset}"
  fi
done

printf '%s' "$out"

# # DISABLED: slow to startup
#
# # --- AI provider quota strip (showy-quota via CodexBar) --------------------
# # Cross-provider quotas (Codex + Claude) from the shared showy-quota cache.
# # The adapter never hard-fails, but guard anyway so a missing install leaves
# # the footer untouched.
# if command -v showy-quota-statusline >/dev/null 2>&1; then
#   quota_strip=$(showy-quota-statusline </dev/null 2>/dev/null) || quota_strip=""
#   [[ -n "$quota_strip" ]] && printf '  %s' "$quota_strip"
# fi
