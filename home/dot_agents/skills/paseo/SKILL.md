---
name: paseo
description: Control Paseo projects, workspaces, scripts, agents, schedules and heartbeats through MCP tools or the CLI. Select senior, worker or scout profiles before delegation, use peer.send for non-interrupting agent messages, and inspect auto-resume after provider usage limits.
---

Paseo is a remote daemon that manages coding agents, terminals. Control it through MCP tools or the CLI.

## Projects

Manage the daemon's project registry through the CLI:

```bash
paseo project create [path]
paseo project ls
paseo project rename <project-id> <name>
paseo project rename <project-id> --reset
paseo project delete <project-id>
```

For a local daemon, `project create` defaults to the current directory and resolves relative paths on the CLI machine. With `--host` or `PASEO_HOST`, always provide a path; the target daemon interprets it on its own machine. Deleting a project archives its active workspaces and removes the project from Paseo without deleting the project directory.

## Workspaces

**`create_workspace`** — create a workspace independently of any agent. Required: `isolation` (`local` or `worktree`). Worktree isolation supports `mode: "branch-off" | "checkout-branch" | "checkout-pr"`: use `branchName`/`baseBranch` for a new branch, `branch` for an existing branch, or `prNumber` plus optional `forge`/`projectPath` for a change request. `worktreeSlug` controls the managed path. Returns the workspace descriptor centered on `workspaceId`.

Choose `baseBranch` explicitly: `origin/main` selects the remote-tracking branch; `refs/heads/main` selects local main. Bare `main` prefers local main when it exists, otherwise origin/main. Paseo retains the resolved ref for workspace comparisons, even after rebasing the branch or changing its PR target.

**`list_workspaces`** — list active workspaces.

**`archive_workspace`** — `{ workspaceId }`. Archives the workspace, its agents, and its terminals. Local directories remain; Paseo removes an owned worktree only after its final active workspace reference is archived.

**`rename_workspace`** — `{ workspaceId, name }`. Rename workspace.

## Workspace scripts

Configured `paseo.json` scripts use the same supervised lifecycle from tools and the CLI.

**`list_workspace_scripts`** — `{ workspaceId }`. Lists configured scripts with lifecycle, service port, proxy URLs, health, exit code, and terminal ID.

**`start_workspace_script`** — `{ workspaceId, scriptName }`. Starts one configured script through Paseo's managed workspace-script launcher and returns its status metadata.

**`stop_workspace_script`** — `{ workspaceId, scriptName }`. Stops a running script through its supervised terminal and returns the stopped status metadata.

The matching CLI surface accepts either an explicit workspace ID or resolves the current directory:

```bash
paseo script ls [--cwd <path> | --workspace <workspace-id>]
paseo script start <name> [--cwd <path> | --workspace <workspace-id>]
paseo script stop <name> [--cwd <path> | --workspace <workspace-id>]
```

## Agents

**`create_agent`** — required: `title`, `provider` (`claude/claude-opus-5-5`, `codex/gpt-6.1-sol`, …), `initialPrompt`. Optional: `workspaceId`, `notifyOnFinish`, `settings`, `labels`. Returns `{ agentId, workspaceId, … }`.

Initial runtime settings live under `settings`: `modeId`, `thinkingOptionId`, and provider-specific `features`. Agent profiles are the preferred source for these values. For Codex fast mode, pass `settings: { features: { "fast_mode": true } }` when creating the agent.

Agent-scoped creation always creates your subagent. Omit `workspaceId` to use your current workspace; pass a workspace returned by `create_workspace` for isolated delegation. Placement never changes parentage.

Detach is an explicit user action in the subagents track, not an agent tool. A cross-workspace child remains your subagent even though it also appears as a normal tab in its workspace.

Agent-scoped `create_agent` defaults `notifyOnFinish` to true. Set it to `false` only for truly fire-and-forget agents.

**`peer.send`** — `{ to, message }`. Use for follow-ups to an existing agent and for any message to another agent. Paseo's `send_agent_prompt` is disabled here because it interrupts a busy recipient's turn and cancels its subagents. `to` takes an agent ID, a unique ID prefix, or an exact title. A working recipient receives the message inside its current turn; an idle one starts a new turn. The message arrives with a `[from:<your-agent-id>]` first line; answer a message by sending to that ID. The call returns on delivery, with no result and no finish notification.

**`update_agent`** — `{ agentId, name?, labels?, settings? }`. Use `settings` for runtime changes on an existing agent: `modeId`, `model`, `thinkingOptionId`, and provider-specific `features`. For Codex fast mode, pass `settings: { features: { "fast_mode": true } }`.

**`list_agents`** — filter by `cwd`, `statuses`, `sinceHours`, `includeArchived`.

**`get_agent_activity`** — `{ agentId, limit? }`. Another agent's recent timeline as a curated summary. `paseo logs <agent-id>` prints the raw log.

**`archive_agent`** — `{ agentId }`. Interrupts if running, removes from active list.

## Permissions

**`list_pending_permissions`** and **`respond_to_permission`** are enabled for agents that need permission coordination. Inspect the actual pending request and respond within the user's authorized scope. These tools do not change the non-interrupting messaging rule: use `peer.send` for agent messages.

## Agent profiles and provider discovery

The managed profiles have three levels of responsibility:

| Profile | Model / reasoning | Role |
| --- | --- | --- |
| `claude-senior` | Opus 5.5 / High | Equal senior counterpart of `codex-senior`; prefer for ambiguous requirements and architecture |
| `codex-senior` | GPT-6.1 Sol / High | Equal senior counterpart of `claude-senior`; prefer for iterative implementation, debugging and tests |
| `claude-worker` | Sonnet 5.5 / Medium | Primary subagent for scoped implementation and substantial investigation |
| `codex-scout` | GPT-6 Luna / Max | Simple, explicit, read-only reconnaissance and factual checks |

"Ask Claude" or "ask Codex" without a tier means the senior profile. Senior colleagues have equal authority and can exchange roles. Prefer different providers for independent review; the same provider or model family is also allowed. Choose helpers by scope and available quota, and follow [paseo-peers](../paseo-peers/SKILL.md) for ownership and coordination.

**`list_profiles`** — named launch bundles configured by the human. Before choosing how to launch a delegated agent, call this tool and read every profile's `notes`. Pick a named profile the user requested, or the profile whose notes best match the work.

There is no `profile` parameter on `create_agent`. Materialize the selected profile into the call:

- combine `provider` and `model` as the `provider/model` value for `create_agent.provider`
- copy `modeId` to `settings.modeId`
- copy `thinkingOptionId` to `settings.thinkingOptionId`
- copy `featureValues` to `settings.features`

Omit absent values. Do not remember a selected profile or infer drift later; a profile is only launch configuration.

If no profile fits, or no profiles are configured, use the provider discovery tools below rather than guessing. Tell the user when you fall back because no configured profile fits.

**`list_providers`** — compact provider availability and modes.

**`list_models`** — full model list for one provider. Use only when you need model IDs or thinking options; the list can be large.

**`inspect_provider`** — compact provider capability and feature inspection. Required: `provider`; pass `cwd` when you are not in an agent-scoped session. Optional: `settings` with draft `model`, `modeId`, `thinkingOptionId`, and `features`.

Only set feature IDs returned by `inspect_provider`. For Codex fast mode, look for `fast_mode` and pass `settings: { features: { "fast_mode": true } }` to `create_agent` or `update_agent`.

## Schedules and heartbeats

**`create_schedule`** — starts a new agent on a cron cadence. Required: `prompt`, `cron`, `provider`. Optional: `timezone`, `name`, `cwd`, `maxRuns`, `expiresIn`. Use when the recurring work should live in fresh agents.

**`create_heartbeat`** — sends you a prompt on a cron cadence. Required: `prompt`, `cron`. Optional: `timezone`, `name`, `maxRuns`, `expiresIn`. Use for reminders, PR/build babysitting, and status checks that should return to this conversation.

**`delete_heartbeat`** stops it. MCP intentionally exposes no heartbeat update tool; delete and recreate when its task or cadence changes.

Schedules have the full list/inspect/update/pause/resume/run-once/log/delete surface. Heartbeats deliberately do not.

## Waiting

Agents take time — 10–30+ minutes is routine. Favor asynchronous workflows.

For agent-scoped `create_agent`, leave `notifyOnFinish` omitted or set it to `true` unless the work is truly fire-and-forget. You will get notified when the target agent finishes or errors. Move on to other work. The notification arrives on its own. A `peer.send` message has no notification; the recipient answers with its own message.

Don't poll `list_agents` or `get_agent_status` to "check on" a running agent. The notification will tell you.

## Usage limits

With the enabled `paseo-resume` plugin, a Claude Code or Codex agent that stops on a provider usage limit gets a persisted resume schedule; its chat shows when. Provider usage is the primary reset source; the plugin falls back to Claude notices with their timezone or Codex local reset messages. A known reset gets two minutes of margin; otherwise the plugin estimates 30 minutes and rechecks the usage API after its five-minute cache expires. Failed delivery retries after five minutes. Do not relaunch or replace it. When its resumed turn finishes, its parent receives a `[from:<agent-id>]` message. A new turn or an archive cancels the pending resume. Authentication errors and ordinary API throttling do not schedule one.

If no resume appears, inspect `paseo plugin ls --json` and `paseo plugin logs paseo-resume`; do not assume the plugin is installed or running. Plugins are maintained by `update-paseo-plugins`, including when the macOS CLI is available only inside Paseo.app.

## CLI semantics

The CLI and tools use the same ownership semantics even where their syntax differs:

```bash
paseo workspace create --isolation worktree --mode branch-off --new-branch fix-x --base origin/main
paseo workspace create --isolation worktree --mode checkout-branch --branch existing-work
paseo workspace create --isolation worktree --mode checkout-pr --pr-number 42
paseo run --provider codex/gpt-6.1-sol --mode full-access --workspace <workspace-id> "<prompt>"
paseo run --provider codex/gpt-6.1-sol --mode full-access --new-workspace worktree --worktree-mode branch-off --new-branch fix-x --base origin/main "<prompt>"
paseo ls
paseo schedule create --cron "*/15 * * * *" "ping main build"
paseo heartbeat create --cron "*/15 * * * *" "check the build"
```

`paseo send` interrupts a running turn, so agents message each other with `peer.send` instead. Discover with `paseo --help` and `paseo <cmd> --help`.
