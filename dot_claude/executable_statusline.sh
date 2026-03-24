#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
jq1() { printf '%s' "$input" | jq -r "$1"; }

model=$(jq1 '.model.display_name // "claude"')
proj=$(jq1 '.workspace.project_dir // .cwd // ""')
used_pct=$(jq1 '.context_window.used_percentage // empty')
ctx_size=$(jq1 '.context_window.context_window_size // 200000')
five_h_used=$(jq1 '.rate_limits.five_hour.used_percentage // empty')
seven_d_used=$(jq1 '.rate_limits.seven_day.used_percentage // empty')
branch=$(git -C "$proj" rev-parse --abbrev-ref HEAD 2>/dev/null || true)

e=$(printf '\033')
R="${e}[0m" BOLD="${e}[1m"
CYAN="${e}[36m" BLUE="${e}[34m" PURPLE="${e}[38;5;141m"
GREEN="${e}[32m" YELLOW="${e}[33m" RED="${e}[31m"
DIM="${e}[38;5;245m"
SEP=" ${DIM}·${R} "

IC_COG=$(printf '\xef\x80\x93')       # U+F013 fa-cog
IC_FOLDER=$(printf '\xef\x81\xbb')    # U+F07B fa-folder-open
IC_BRANCH=$(printf '\xee\x9c\xa5')    # U+E725 nf-dev-git_branch
IC_BAR=$(printf '\xef\x82\x80')       # U+F080 fa-bar-chart
IC_HOURGLASS=$(printf '\xef\x89\x92') # U+F252 fa-hourglass-half
IC_CAL=$(printf '\xef\x81\xb3')       # U+F073 fa-calendar

fmt_k() { awk "BEGIN{n=$1; if(n>=1e6)printf \"%.1fm\",n/1e6; else if(n>=1e3)printf \"%.0fk\",n/1e3; else printf \"%d\",n}"; }

# green→yellow→red as value rises (used%)
usage_color() {
	if [[ $1 -ge 90 ]]; then
		printf '%s' "$RED"
	elif [[ $1 -ge 70 ]]; then
		printf '%s' "$YELLOW"
	else printf '%s' "$GREEN"; fi
}

# green→yellow→red as value falls (remaining%)
remaining_color() {
	if [[ $1 -le 20 ]]; then
		printf '%s' "$RED"
	elif [[ $1 -le 50 ]]; then
		printf '%s' "$YELLOW"
	else printf '%s' "$GREEN"; fi
}

# Append a rate-limit segment: icon label remaining%
rate_seg() {
	local rem col
	rem=$(awk "BEGIN{printf \"%.0f\", 100 - $3}")
	col=$(remaining_color "$rem")
	printf '%s' "${SEP}${DIM}${1} ${2}${R} ${col}${BOLD}${rem}%${R}"
}

line="${CYAN}${IC_COG} ${model}${R}"

[[ -n $proj ]] && line+="${SEP}${BLUE}${IC_FOLDER} $(basename "$proj")${R}"

[[ -n $branch && $branch != HEAD ]] && line+="${SEP}${BOLD}${PURPLE}${IC_BRANCH} ${branch}${R}"

if [[ -n $used_pct ]]; then
	pct=$(printf '%.0f' "$used_pct")
	col=$(usage_color "$pct")
	used_tokens=$(awk "BEGIN{printf \"%.0f\", $used_pct * $ctx_size / 100}")
	used_fmt=$(fmt_k "$used_tokens")
	total_fmt=$(fmt_k "$ctx_size")
	filled=$((pct * 8 / 100))
	bar_f='' bar_e=''
	for ((i = 0; i < filled; i++)); do bar_f+='▓'; done
	for ((i = 0; i < 8 - filled; i++)); do bar_e+='░'; done
	line+="${SEP}${DIM}${IC_BAR}${R} ${col}${used_fmt}${DIM}/${total_fmt} ${col}${BOLD}${bar_f}${DIM}${bar_e}${R} ${col}${BOLD}${pct}%${R}"
fi

[[ -n $five_h_used ]] && line+=$(rate_seg "$IC_HOURGLASS" "5h" "$five_h_used")
[[ -n $seven_d_used ]] && line+=$(rate_seg "$IC_CAL" "7d" "$seven_d_used")

printf '%s' "$line"
