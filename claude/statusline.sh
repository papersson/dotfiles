#!/bin/bash

# Claude Code statusline - H3 style (square left, rounded right)
# Peach git + Teal model with gradient pills

input=$(cat)

# ─────────────────────────────────────────────────────────────────────────────
# Nerd Font Icons
# ─────────────────────────────────────────────────────────────────────────────
ICON_GIT=$'\xee\x82\xa0'      # U+E0A0
ICON_SPARKLE=$'\xe2\x9c\xa6'  # ✦
ICON_UP=$'\xef\x81\xa2'       # U+F062
ICON_DOWN=$'\xef\x81\xa3'     # U+F063
ICON_STASH=$'\xef\x80\x9c'    # U+F01C
ROUND_RIGHT=$'\xee\x82\xb4'   # U+E0B4

# ─────────────────────────────────────────────────────────────────────────────
# True Color - Catppuccin Mocha
# ─────────────────────────────────────────────────────────────────────────────
tc_fg() { printf '\033[38;2;%d;%d;%dm' "$1" "$2" "$3"; }
tc_bg() { printf '\033[48;2;%d;%d;%dm' "$1" "$2" "$3"; }

FG_PEACH=$(tc_fg 250 179 135)
FG_TEAL=$(tc_fg 148 226 213)
FG_GREEN=$(tc_fg 166 227 161)
FG_YELLOW=$(tc_fg 249 226 175)
FG_RED=$(tc_fg 243 139 168)
FG_TEXT=$(tc_fg 205 214 244)
FG_SUBTEXT=$(tc_fg 166 173 200)
FG_OVERLAY=$(tc_fg 108 112 134)
FG_SURFACE0=$(tc_fg 49 50 68)
FG_CRUST=$(tc_fg 17 17 27)

BG_PEACH=$(tc_bg 250 179 135)
BG_TEAL=$(tc_bg 148 226 213)
BG_SURFACE0=$(tc_bg 49 50 68)

NC='\033[0m'

# ─────────────────────────────────────────────────────────────────────────────
# Extract JSON data
# ─────────────────────────────────────────────────────────────────────────────
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // "~"')

# Context window
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
current_usage=$(echo "$input" | jq '.context_window.current_usage')

if [ "$current_usage" != "null" ]; then
    current_tokens=$(echo "$current_usage" | jq '(.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)')
    context_percent=$((current_tokens * 100 / context_size))
else
    current_tokens=0
    context_percent=0
fi

tokens_display=$(awk "BEGIN {printf \"%.0fk\", $current_tokens/1000}")

# Cost
session_cost_raw=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
cost_info=""
if [ -n "$session_cost_raw" ] && [ "$session_cost_raw" != "null" ]; then
    session_cost=$(printf "%.2f" "$session_cost_raw")
    cost_info="  ${FG_OVERLAY}\$${session_cost}${NC}"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Context Progress Bar
# ─────────────────────────────────────────────────────────────────────────────
if [ "$context_percent" -lt 50 ]; then
    BAR_COLOR="$FG_GREEN"
elif [ "$context_percent" -lt 75 ]; then
    BAR_COLOR="$FG_YELLOW"
else
    BAR_COLOR="$FG_RED"
fi

bar_width=10
filled=$((context_percent * bar_width / 100))
empty=$((bar_width - filled))
bar=""
for ((i=0; i<filled; i++)); do bar+="━"; done
for ((i=0; i<empty; i++)); do bar+="─"; done

context_info="${BAR_COLOR}${bar}${NC} ${BAR_COLOR}${context_percent}%${NC} ${FG_OVERLAY}${tokens_display}${NC}"

# ─────────────────────────────────────────────────────────────────────────────
# Git Information
# ─────────────────────────────────────────────────────────────────────────────
cd "$current_dir" 2>/dev/null || cd /

git_pill=""
git_extra=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null)
    [ -z "$branch" ] && branch="detached"

    status_output=$(git status --porcelain 2>/dev/null)
    is_dirty=false
    [ -n "$status_output" ] && is_dirty=true

    # Build the git pill: [icon] branch
    git_pill="${BG_PEACH}${FG_CRUST} ${ICON_GIT} ${NC}${FG_PEACH}${BG_SURFACE0} ${branch} ${NC}${FG_SURFACE0}${ROUND_RIGHT}${NC}"

    # Extra info after pill
    extra_parts=""

    # Upstream tracking
    upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    if [ -n "$upstream" ]; then
        ahead_behind=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
        ahead=$(echo "$ahead_behind" | cut -f1)
        behind=$(echo "$ahead_behind" | cut -f2)

        sync_info=""
        [ "$ahead" -gt 0 ] 2>/dev/null && sync_info="${sync_info}${ICON_UP}${ahead}"
        [ "$behind" -gt 0 ] 2>/dev/null && sync_info="${sync_info}${ICON_DOWN}${behind}"
        [ -n "$sync_info" ] && extra_parts="${extra_parts} ${FG_OVERLAY}${sync_info}${NC}"
    fi

    # Stash
    stash_count=$(git stash list 2>/dev/null | wc -l | xargs)
    [ "$stash_count" -gt 0 ] 2>/dev/null && extra_parts="${extra_parts} ${FG_OVERLAY}${ICON_STASH}${stash_count}${NC}"

    # Changes
    if [ "$is_dirty" = true ]; then
        total_files=$(echo "$status_output" | wc -l | xargs)
        line_stats=$(git diff --numstat 2>/dev/null | awk '{added+=$1; removed+=$2} END {print added+0, removed+0}')
        added=$(echo $line_stats | cut -d' ' -f1)
        removed=$(echo $line_stats | cut -d' ' -f2)

        changes=""
        [ "$added" -gt 0 ] && changes="+${added}"
        [ "$removed" -gt 0 ] && changes="${changes}-${removed}"

        if [ -z "$changes" ] && [ "$total_files" -gt 0 ]; then
            changes="${total_files}Δ"
        fi
        [ -n "$changes" ] && extra_parts="${extra_parts} ${FG_PEACH}${changes}${NC}"
    fi

    git_extra="$extra_parts"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Output
# ─────────────────────────────────────────────────────────────────────────────
display_dir="${current_dir/#$HOME/~}"

# Line 1: Path + Git pill + extras
if [ -n "$git_pill" ]; then
    echo -e "${FG_TEXT}${display_dir}${NC}  ${git_pill}${git_extra}"
else
    echo -e "${FG_TEXT}${display_dir}${NC}"
fi

# Line 2: Model pill + Context + Cost
model_pill="${BG_TEAL}${FG_CRUST} ${ICON_SPARKLE} ${NC}${FG_TEAL}${BG_SURFACE0} ${model_name} ${NC}${FG_SURFACE0}${ROUND_RIGHT}${NC}"
echo -e "${model_pill} ${context_info}${cost_info}"
