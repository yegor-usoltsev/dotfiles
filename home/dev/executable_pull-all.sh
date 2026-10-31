#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

# Fast-forward every checkout on its default branch; others are only listed.
# 🟢 pulled, 🟡 on another branch, 🔴 failed.
for repo in ~/dev ~/dev/* ~/dev/*/*; do
	[[ $repo == "$HOME/dev/tmp" || $repo == "$HOME/dev/tmp/"* ]] && continue
	[[ -e "$repo/.git" ]] || continue
	icon='🔴'
	if branch=$(git -C "$repo" branch --show-current 2>/dev/null); then
		case "$branch" in
		main | master | develop)
			if git -C "$repo" pull --ff-only >/dev/null 2>&1; then icon='🟢'; fi
			;;
		*) icon='🟡' ;;
		esac
	fi
	printf '%s %s\n' "$icon" "$repo"
done
