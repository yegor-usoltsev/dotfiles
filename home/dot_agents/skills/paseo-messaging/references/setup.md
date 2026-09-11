# Paseo peer setup

Read this only when installing or changing the workflow.

## Agent profiles

Keep three profiles in **Settings -> host -> Agents -> Agent profiles**. Profiles configure human-launched sessions; `p` contains the settings for peer launches because the Paseo CLI cannot read profile notes.

| Name | Provider | Model | Thinking | Mode |
| --- | --- | --- | --- | --- |
| `worker-codex` | Codex | `gpt-5.6-sol` | `high` | `full-access` |
| `worker-claude` | Claude | `claude-opus-5` | `high` | `bypassPermissions` |
| `scout` | Codex | `gpt-5.6-luna` | `max` | `full-access` |

Make `worker-codex` the default profile. Use these notes:

### `worker-codex`

```text
Default worker. When the human starts you, own the task and usually implement it. Review changes written by worker-claude. When another agent starts you, complete only the assignment, report to the named owner, and never launch another agent. Use paseo-messaging for peer work.
```

### `worker-claude`

```text
Second worker. Review changes written by worker-codex. Build after worker-codex has failed the same assignment twice or when the human selects this profile. When another agent starts you, complete only the assignment, report to the named owner, and never launch another agent. Use paseo-messaging for peer work.
```

### `scout`

```text
Read-only reconnaissance. Trace symbols and callers, inspect relevant tests and conventions, and return concise file:line evidence. Never edit repository files, make design decisions, review a diff, or launch another agent. Use only when reconnaissance saves substantial worker reading. Keep thinking at max.
```

## Tool injection and bundled skills

Keep the MCP server available but disable tool injection into agents in `~/.paseo/config.json`:

```json
{
  "daemon": {
    "mcp": {
      "enabled": true,
      "injectIntoAgents": false
    }
  }
}
```

Paseo owns that file, so set those two keys in place, delete `daemon.appendSystemPrompt` when an earlier orchestration block left one, and leave everything else alone. Reload Paseo and start fresh agent sessions afterwards, because a running session keeps the tools and prompt it received at launch.

Disable the bundled `paseo`, `paseo-handoff`, `paseo-advisor`, and `paseo-committee` skills in Paseo settings. Keep `zmx-messaging` for zmx and `paseo-messaging` for Paseo.

The global `AGENTS.md` and this skill replace the removed orchestration prompt.

## Smoke test

Run this after changing the wrapper, model matrix, or Paseo version:

1. Start a disposable top-level worker and authorize one peer launch.
2. Run `p init` and create a read-only assignment.
3. Launch a scout. Confirm the returned ID, `PASEO_PEER_*` environment, report file, and reply to `owner`.
4. Launch a cross-family reviewer in the owner's workspace. Confirm the first review and a second pass over a fix diff.
5. Archive the disposable agents by full ID.

Check `paseo --help` and update the wrapper when a release changes the interface it calls.
