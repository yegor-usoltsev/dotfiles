# Paseo semantics

What the tool schemas and `--help` leave out. Read only the section you need.

## Agents and messages

- Agent-scoped `create_agent` always creates your child; a `workspaceId` changes placement, not parentage. Detaching a child is a user action.
- `peer.send` takes an agent ID, a unique ID prefix or an exact title. It steers a running turn or starts one on an idle agent, prefixed with `[from:<sender-id>]`. It returns on delivery, which means accepted, not read; there is no finish notification, so the recipient answers with its own message.
- `paseo send` interrupts a running turn and can cancel the recipient's children; `send_agent_prompt` does the same and is disabled here.
- Use `update_agent` with `settings` to change a running agent's mode, model, thinking option or features. Set only feature IDs that `inspect_provider` returns.
- When no profile fits, use `list_providers`, `inspect_provider` and, only for exact model IDs, `list_models`; tell the user you fell back.
- `list_pending_permissions` and `respond_to_permission` answer an agent's real permission request within the user's authorized scope.

## Workspaces and scripts

- Choose `baseBranch` explicitly: `origin/main` is the remote-tracking branch, `refs/heads/main` is local, and bare `main` prefers local when it exists. Paseo keeps the resolved base for comparisons even after a rebase.
- `archive_workspace` archives its agents and terminals. Directories stay; Paseo removes an owned worktree only after its last active workspace is archived. Save unfinished work first.
- Run configured `paseo.json` scripts through `list_workspace_scripts`, `start_workspace_script` and `stop_workspace_script` (or `paseo script`), so Paseo tracks health, ports and proxy URLs.
- `paseo project` manages the project registry. With `--host` or `PASEO_HOST`, pass an explicit path, because the target daemon resolves it. Deleting a project archives its workspaces and keeps the directory.

## Heartbeats and schedules

- A heartbeat (`create_heartbeat`) sends a prompt back into your own conversation on a cron. Use it to babysit CI or a PR, or to drive `plan-loop`. Bound it with `maxRuns` or `expiresIn`, give it a stable name, and delete it when the job is done; MCP has no update, so recreate it to change the cadence.
- A schedule (`create_schedule`) starts a fresh agent on a cron, for recurring maintenance such as backlog triage or dependency updates. Each run's agent is archived when its turn ends, including on a usage limit, so the prompt reads saved progress from a file and writes it back.

Adapt this schedule prompt:

```text
Read <checkpoint file>. If its goal is met, delete this schedule and report the result.
If it needs a product decision, access or authorization, write the question to the checkpoint and stop.
Otherwise take the next bounded step, leaving work that an active agent owns alone.
Save the result, checks, open issues and next step to the checkpoint.
```

## Usage limits and plugins

- With `paseo-resume` enabled, a usage-limit stop gets a persisted resume job, shown in the agent's chat. `peer.send` messages and heartbeats keep the job; an explicit cancel or archive drops it. Authentication errors and short API throttling get no job.
- When a resumed child finishes, its parent receives a `[from:<child-id>]` notice.
- If a resume never appears, check `paseo plugin ls --json` and `paseo plugin logs paseo-resume`, and read the plugin's README for its reset timing. `update-paseo-plugins` installs and updates `paseo-peer` and `paseo-resume`.
