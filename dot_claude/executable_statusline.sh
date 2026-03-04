#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd')
model=$(printf '%s' "$input" | jq -r '.model.display_name // "claude"')
left_pct=$(printf '%s' "$input" | jq -r '.context_window.remaining_percentage // 0')
used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // 0')
total_in=$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(printf '%s' "$input" | jq -r '.context_window.total_output_tokens // 0')

branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
repo=$(basename "$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || true)

if [[ -z $repo ]]; then
	proj=$(printf '%s' "$input" | jq -r '.workspace.project_dir // ""')
	[[ -n $proj ]] && repo=$(basename "$proj")
fi

fmt() {
	printf '%s' "$1" | awk '{if($1>=1000000)printf "%.1fm",$1/1000000; else if($1>=1000)printf "%.0fk",$1/1000; else printf "%d",$1}'
}
in_fmt=$(fmt "$total_in")
out_fmt=$(fmt "$total_out")

e=$(printf '\033')
CYAN="${e}[36m"
BLUE="${e}[34m"
YELLOW="${e}[33m"
GREEN="${e}[32m"
DIM="${e}[2m"
R="${e}[0m"
SEP=" ${DIM}·${R} "

line="${CYAN}${model}${R}${SEP}${BLUE}${cwd/#$HOME/~}${R}"
[[ -n $repo ]] && line="${line}${SEP}${YELLOW}${repo}${R}"
[[ -n $branch ]] && line="${line}${SEP}${GREEN}${branch}${R}"
line="${line}${SEP}${left_pct}% left"
line="${line}${SEP}${used_pct}% used"
line="${line}${SEP}${in_fmt} in${SEP}${out_fmt} out"

printf '%s' "$line"
