#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
jq1() { printf '%s' "$input" | jq -r "$1"; }

model=$(jq1 '.model.display_name // "claude"')
proj=$(jq1 '.workspace.project_dir // .cwd // ""')
used_pct=$(jq1 '.context_window.used_percentage // empty')
ctx_size=$(jq1 '.context_window.context_window_size // 200000')
lines_added=$(jq1 '.cost.total_lines_added // 0')
lines_removed=$(jq1 '.cost.total_lines_removed // 0')
branch=
[[ -z $proj ]] || branch=$(git -C "$proj" rev-parse --abbrev-ref HEAD 2>/dev/null || true)

e=$'\033'
R="${e}[0m" BOLD="${e}[1m"
CYAN="${e}[36m" BLUE="${e}[34m" PURPLE="${e}[38;5;141m"
GREEN="${e}[32m" YELLOW="${e}[33m" RED="${e}[31m"
DIM="${e}[38;5;245m"
SEP=" ${DIM}·${R} "

IC_COG='' IC_FOLDER='' IC_BRANCH='' IC_BAR=''
IC_HOURGLASS='' IC_CAL='' IC_CODE='' IC_REFRESH=''

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

# --- Line 1: model, dir, branch, lines changed ---
line1="${CYAN}${IC_COG} ${model}${R}"

[[ -n $proj ]] && line1+="${SEP}${BLUE}${IC_FOLDER} $(basename "$proj")${R}"

[[ -n $branch && $branch != HEAD ]] && line1+="${SEP}${BOLD}${PURPLE}${IC_BRANCH} ${branch}${R}"

line1+="${SEP}${DIM}${IC_CODE}${R} ${GREEN}+${lines_added}${R} ${RED}-${lines_removed}${R}"

# --- Line 2: context usage, rate limits with reset times ---
line2=""

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
	line2+="${DIM}${IC_BAR}${R} ${col}${used_fmt}${DIM}/${total_fmt} ${col}${BOLD}${bar_f}${DIM}${bar_e}${R} ${col}${BOLD}${pct}%${R}"
fi

for period in five_hour seven_day; do
	read -r used resets < <(jq1 ".rate_limits.$period | select(.used_percentage != null) | [.used_percentage, (.resets_at // \"\")] | @tsv") || continue
	case $period in
	five_hour) label="${IC_HOURGLASS} 5h" format='+%H:%M' ;;
	seven_day) label="${IC_CAL} 7d" format='+%a' ;;
	esac
	rem=$(awk "BEGIN{printf \"%.0f\", 100 - $used}")
	col=$(remaining_color "$rem")
	[[ -n $line2 ]] && line2+="${SEP}"
	line2+="${DIM}${label}${R} ${col}${BOLD}${rem}%${R}"
	if [[ -n $resets ]]; then
		reset=$(date -r "$resets" "$format" 2>/dev/null || date -d "@$resets" "$format" 2>/dev/null || true)
		[[ -n $reset ]] && line2+=" ${DIM}${IC_REFRESH} ${reset}${R}"
	fi
done

printf '%s\n' "$line1"
if [[ -n $line2 ]]; then
	printf '%s' "$line2"
fi
