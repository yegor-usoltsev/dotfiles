---
name: paseo-messaging
description: Launch Paseo peers with the native CLI and exchange messages through p. Use for subagents, delegation, second opinions, peer review, reconnaissance, or messages to a supplied Paseo agent ID.
---

# Peer messaging on Paseo

Use `paseo run` to launch and `p send` to message. Both require a running Paseo daemon; `p` also needs Bash.

## Launch

Use these defaults; the user's model choice takes precedence:

| Work | `--provider` | `--thinking` | `--mode` |
| --- | --- | --- | --- |
| Implementation, Codex review | `codex/gpt-6.1-sol` | `high` | `full-access` |
| Claude implementation or review | `claude/claude-opus-5-5` | `high` | `bypassPermissions` |
| Read-only reconnaissance | `codex/gpt-6-luna` | `max` | `full-access` |

Sol implementation may use `medium` for a narrow assignment or `low` for mechanical work. Review with the other family unless the user specifies otherwise. Give reconnaissance a read-only brief and ask for file:line evidence.

Outside Paseo (`PASEO_AGENT_ID` is unset), use the harness's native subagents with these model defaults or the closest available equivalents. Native subagents return through the harness; do not use `p send owner` or the launch example below.

State the objective, known context, scope, expected result, and checks. Tell the peer to load this skill, reply with `p send owner`, and stop after replying. Use a message by default; put long or durable context in a shared file with one writer.

```sh
paseo run --background --json --title "Implementation peer" \
	--provider codex/gpt-6.1-sol --thinking high --mode full-access \
	--env "PASEO_PEER_OWNER_ID=${PASEO_AGENT_ID:?Run inside a Paseo agent}" \
	"Use paseo-messaging. <brief> Reply with p send owner; then stop."
```

Record the returned full `agentId`. Omit workspace flags to reuse the caller's workspace, or pass `--workspace` for an existing checkout. Stop editing before handing a shared checkout to another editor; never create a worktree for review. Use an isolated worktree only for parallel implementation or when requested; consult `paseo workspace create --help` and retain its workspace ID. `run --json` does not return that ID.

## Messages and waiting

```sh
p send <agent-id> "<action or result>"
p send <agent-id> --prompt-file /absolute/path/brief.md
p send owner "<outcome, changed paths or commits, checks, unresolved questions>"
```

`p` adds `[from:<agent-id>]`, resolves `owner` through `PASEO_PEER_OWNER_ID`, and sends with `--no-wait`.

Send results, new evidence, or necessary questions; skip acknowledgments and routine progress. Continue independent work while waiting. When the reply is the next dependency, end the turn; the peer's message resumes it. Do not poll status or logs. Verify the claimed result rather than treating delivery or idle status as completion.

For a failed command or missing reply, inspect the exact agent once with `paseo inspect --json <agent-id>` and, if needed, `paseo logs <agent-id> --tail 12`. Recover lost IDs with `paseo ls --global --all --json`. After an ambiguous launch, find the agent before retrying. Archive only known task agents; archive an isolated workspace only after its commits are integrated and its path is no longer needed.
