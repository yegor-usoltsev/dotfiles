#!/usr/bin/env bash
set -euo pipefail

script=${1:-home/dot_local/bin/executable_paseo-peer}
original_path=$PATH
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT

mkdir -p "$test_root/bin" "$test_root/home" "$test_root/repo"
fake_paseo=$test_root/bin/paseo
call_log=$test_root/paseo.log
export PASEO_PEER_TEST_LOG=$call_log

cat >"$fake_paseo" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

{
	printf 'CALL'
	printf ' <%s>' "$@"
	printf '\n'
} >>"$PASEO_PEER_TEST_LOG"

case ${1:-} in
agent)
	printf '{"status":"updated"}\n'
	;;
workspace)
	printf '{"workspaceId":"wks-test"}\n'
	;;
run)
	printf '{"agentId":"agent-test","status":"running"}\n'
	;;
inspect)
	if [[ $* == *closed-agent* ]]; then
		printf '{"Status":"closed"}\n'
	else
		printf '{"Status":"idle"}\n'
	fi
	;;
send)
	prompt_file=
	while (($#)); do
		if [[ $1 == --prompt-file ]]; then
			prompt_file=$2
			break
		fi
		shift
	done
	{
		printf 'PROMPT\n'
		cat "$prompt_file"
		printf 'END PROMPT\n'
	} >>"$PASEO_PEER_TEST_LOG"
	printf '{"agentId":"peer-test","status":"sent"}\n'
	;;
*)
	printf 'unexpected paseo command: %s\n' "$*" >&2
	exit 64
	;;
esac
EOF
chmod +x "$fake_paseo"

export HOME=$test_root/home
export PATH=$test_root/bin:/usr/bin:/bin:$original_path
export PASEO_AGENT_CWD=$test_root/repo
export PASEO_AGENT_ID=owner-test
export PASEO_PEER_PASEO=$fake_paseo

task_dir=$(bash "$script" init demo)
[[ $task_dir == "$HOME/.paseo/demo" ]]
[[ -f $task_dir/task.md ]]
[[ -d $task_dir/assignments ]]
[[ -d $task_dir/reports ]]
[[ -d $task_dir/reviews ]]
printf 'Objective: inspect the parser.\n' >"$task_dir/assignments/scout.md"
printf 'Objective: implement the parser.\n' >"$task_dir/assignments/build.md"
printf 'Objective: review the parser.\n' >"$task_dir/assignments/review.md"

spawn_json=$(bash "$script" spawn scout \
	--task demo \
	--assignment assignments/scout.md)
[[ -n $spawn_json ]]
jq -e '.agentId == "agent-test" and .workspaceId == null and .role == "scout"' <<<"$spawn_json" >/dev/null
jq -e '.report | endswith("/reports/scout.md")' <<<"$spawn_json" >/dev/null
grep -F '<--provider> <codex/gpt-5.6-luna>' "$call_log" >/dev/null
grep -F '<--thinking> <max>' "$call_log" >/dev/null
grep -F '<--env> <PASEO_PEER_OWNER_ID=owner-test>' "$call_log" >/dev/null
grep -F '<--label> <task=demo>' "$call_log" >/dev/null
grep -F '<Objective: complete the assigned scout work for demo.' "$call_log" >/dev/null
grep -F 'Do not edit repository files or task coordination files except your report.' "$call_log" >/dev/null

: >"$call_log"
worktree_json=$(bash "$script" spawn builder \
	--task demo \
	--assignment assignments/build.md \
	--worktree feature/demo \
	--base main)
jq -e '.workspaceId == "wks-test" and .role == "builder"' <<<"$worktree_json" >/dev/null
jq -e '.report | endswith("/reports/build.md")' <<<"$worktree_json" >/dev/null
grep -F '<--provider> <codex/gpt-5.6-sol>' "$call_log" >/dev/null
grep -F '<--workspace> <wks-test>' "$call_log" >/dev/null
grep -F 'Edit only the assigned implementation slice in the isolated worktree.' "$call_log" >/dev/null

: >"$call_log"
bash "$script" spawn builder \
	--task demo \
	--family claude \
	--assignment assignments/build.md \
	--worktree feature/claude-demo \
	--base main >/dev/null
grep -F '<--provider> <claude/claude-opus-5>' "$call_log" >/dev/null

: >"$call_log"
review_json=$(bash "$script" spawn reviewer \
	--task demo \
	--for codex \
	--assignment assignments/review.md \
	--workspace current-workspace)
jq -e '.workspaceId == "current-workspace" and .role == "reviewer"' <<<"$review_json" >/dev/null
jq -e '.report | endswith("/reviews/review.md")' <<<"$review_json" >/dev/null
grep -F '<--provider> <claude/claude-opus-5>' "$call_log" >/dev/null
grep -F 'Read the assigned diff first, inspect only touched code and directly relevant definitions' "$call_log" >/dev/null

: >"$call_log"
bash "$script" spawn reviewer \
	--task demo \
	--for claude \
	--assignment assignments/review.md >/dev/null
grep -F '<--provider> <codex/gpt-5.6-sol>' "$call_log" >/dev/null

bash "$script" send peer-test --task demo 'Review the report.' >/dev/null
grep -F '[from:owner-test task:demo]' "$call_log" >/dev/null
grep -F 'Review the report.' "$call_log" >/dev/null

printf 'Read the shared finding.\n' >"$test_root/message.md"
bash "$script" send peer-test --task demo --prompt-file "$test_root/message.md" >/dev/null
grep -F 'Read the shared finding.' "$call_log" >/dev/null

PASEO_PEER_OWNER_ID=owner-peer PASEO_PEER_TASK=demo \
	bash "$script" send owner 'Done.' >/dev/null
grep -F '<inspect> <--json> <owner-peer>' "$call_log" >/dev/null

if PASEO_PEER_OWNER_ID=owner-peer bash "$script" spawn scout \
	--task demo \
	--assignment assignments/scout.md >/dev/null 2>&1; then
	printf 'recursive spawn unexpectedly succeeded\n' >&2
	exit 1
fi

if bash "$script" spawn builder \
	--task demo \
	--assignment assignments/build.md >/dev/null 2>&1; then
	printf 'builder without a worktree unexpectedly succeeded\n' >&2
	exit 1
fi

if bash "$script" spawn reviewer \
	--task demo \
	--assignment assignments/review.md >/dev/null 2>&1; then
	printf 'reviewer without --for unexpectedly succeeded\n' >&2
	exit 1
fi

if bash "$script" spawn scout \
	--task demo \
	--family claude \
	--assignment assignments/scout.md >/dev/null 2>&1; then
	printf 'scout with a model override unexpectedly succeeded\n' >&2
	exit 1
fi

if bash "$script" spawn reviewer \
	--task demo \
	--for codex \
	--assignment assignments/review.md \
	--worktree review/demo \
	--base main >/dev/null 2>&1; then
	printf 'reviewer worktree unexpectedly succeeded\n' >&2
	exit 1
fi

if bash "$script" send closed-agent --task demo 'Hello.' >/dev/null 2>&1; then
	printf 'send to closed agent unexpectedly succeeded\n' >&2
	exit 1
fi

if bash "$script" init ../invalid >/dev/null 2>&1; then
	printf 'invalid task name unexpectedly succeeded\n' >&2
	exit 1
fi
