#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# ─────────────────────────────────────────────────────────────────────────────
# Nerd Font Icons (UTF-8 hex encoding for bash 3.2 compatibility)
# ─────────────────────────────────────────────────────────────────────────────
ICON_GIT=$'\xee\x82\xa0'      # U+E0A0
ICON_UP=$'\xef\x81\xa2'       # U+F062
ICON_DOWN=$'\xef\x81\xa3'     # U+F063
ICON_STASH=$'\xef\x80\x9c'    # U+F01C

# ─────────────────────────────────────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────────────────────────────────────
WHITE='\033[1;37m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
DIM='\033[0;90m'
NC='\033[0m'

# Separator
SEP="${DIM}|${NC}"

# ─────────────────────────────────────────────────────────────────────────────
# Extract JSON data
# ─────────────────────────────────────────────────────────────────────────────
model_name=$(echo "$input" | jq -r '.model.display_name')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')

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
    cost_info=" ${SEP} ${DIM}\$${session_cost}${NC}"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Context Progress Bar
# ─────────────────────────────────────────────────────────────────────────────
if [ "$context_percent" -lt 50 ]; then
    BAR_COLOR="${GREEN}"
elif [ "$context_percent" -lt 75 ]; then
    BAR_COLOR="${YELLOW}"
else
    BAR_COLOR="${RED}"
fi

bar_width=12
filled=$((context_percent * bar_width / 100))
empty=$((bar_width - filled))
bar=""
for ((i=0; i<filled; i++)); do bar+="━"; done
for ((i=0; i<empty; i++)); do bar+="─"; done

context_info="${BAR_COLOR}${bar}${NC} ${BAR_COLOR}${context_percent}%${NC} ${DIM}${tokens_display}${NC}"

# ─────────────────────────────────────────────────────────────────────────────
# Git Information
# ─────────────────────────────────────────────────────────────────────────────
cd "$current_dir" 2>/dev/null || cd /

git_info=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null)
    [ -z "$branch" ] && branch="detached"

    # Check if dirty
    status_output=$(git status --porcelain 2>/dev/null)
    is_dirty=false
    [ -n "$status_output" ] && is_dirty=true

    # Choose color based on state: yellow if dirty, dim if clean
    if [ "$is_dirty" = true ]; then
        GIT_COLOR="${YELLOW}"
    else
        GIT_COLOR="${DIM}"
    fi

    # Branch with icon
    git_info="${GIT_COLOR}${ICON_GIT}${branch}${NC}"

    # Upstream tracking
    upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
    if [ -n "$upstream" ]; then
        ahead_behind=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
        ahead=$(echo "$ahead_behind" | cut -f1)
        behind=$(echo "$ahead_behind" | cut -f2)

        sync_info=""
        [ "$ahead" -gt 0 ] 2>/dev/null && sync_info="${sync_info}${ICON_UP}${ahead}"
        [ "$behind" -gt 0 ] 2>/dev/null && sync_info="${sync_info}${ICON_DOWN}${behind}"
        [ -n "$sync_info" ] && git_info="${git_info} ${DIM}${sync_info}${NC}"
    fi

    # Stash
    stash_count=$(git stash list 2>/dev/null | wc -l | xargs)
    [ "$stash_count" -gt 0 ] 2>/dev/null && git_info="${git_info} ${DIM}${ICON_STASH}${stash_count}${NC}"

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
        [ -n "$changes" ] && git_info="${git_info} ${GIT_COLOR}${changes}${NC}"
    fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# Output
# ─────────────────────────────────────────────────────────────────────────────
display_dir="${current_dir/#$HOME/~}"

# Line 1: Path + Git
echo -e "${WHITE}${display_dir}${NC}${git_info:+ ${git_info}}"

# Line 2: Sparkle + Model + Context + Cost
echo -e "${CYAN}✦ ${model_name}${NC} ${SEP} ${context_info}${cost_info}"
