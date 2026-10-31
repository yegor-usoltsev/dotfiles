#!/usr/bin/env bash
set -euo pipefail

# Clone the repositories listed below from GitHub and Gitea into
# ~/dev/<owner>/<name>, skipping forks, mirrors, archived repositories and
# existing checkouts. New checkouts become T3 Code projects.
cd "$(dirname "$0")"

# An owner clones all of its repositories; owner/name clones one.
allowed=(
	yegor-usoltsev
	yegor
	chasovsky
	intuitio
	renovate-bot
)

is_allowed() {
	local entry
	for entry in "${allowed[@]}"; do
		[[ $1 == "$entry" || ${1%%/*} == "$entry" ]] && return 0
	done
	return 1
}

repos() {
	gh api --paginate 'user/repos?affiliation=owner,organization_member&per_page=100' \
		--jq '.[] | select((.fork or .archived or .mirror_url != null) | not) | "\(.full_name) \(.ssh_url)"'
	local page=1 batch
	while batch=$(tea api "/user/repos?limit=50&page=$page") && [[ $(jq length <<<"$batch") -gt 0 ]]; do
		jq -r '.[] | select((.fork or .archived or .mirror) | not) | "\(.full_name) \(.clone_url)"' <<<"$batch"
		page=$((page + 1))
	done
}

repos | sort -u | while read -r name url; do
	is_allowed "$name" || continue
	[[ -e $name ]] && continue
	git clone --quiet "$url" "$name" </dev/null
	printf 'cloned %s\n' "$name"
	if command -v t3 >/dev/null 2>&1; then
		t3 project add "$PWD/$name" >/dev/null 2>&1 </dev/null || true
	fi
done
