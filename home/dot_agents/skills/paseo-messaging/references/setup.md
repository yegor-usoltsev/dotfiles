# Paseo peer setup

Read this only when installing or changing the workflow.

## Agent profiles

Keep three profiles in **Settings -> host -> Agents -> Agent profiles**. Profiles configure human-launched sessions; `p` contains the settings for peer launches because the Paseo CLI cannot read profile notes.

| Name | Provider | Model | Thinking | Mode |
| --- | --- | --- | --- | --- |
| `worker-codex` | Codex | `gpt-6-sol` | `high` | `full-access` |
| `worker-claude` | Claude | `claude-opus-5-5` | `high` | `bypassPermissions` |
| `scout` | Codex | `gpt-6-luna` | `max` | `full-access` |

Make `worker-codex` the default profile. Use these notes:

### `worker-codex`

```text
Default worker. When the human starts you, own the task and usually implement it. Review and fix changes written by worker-claude. When another agent starts you, complete only the assignment, report to the named owner, and never launch another agent. Use paseo-messaging for peer work.
```

### `worker-claude`

```text
Second worker. Review and fix changes written by worker-codex. Build after worker-codex has failed the same assignment twice or when the human selects this profile. When another agent starts you, complete only the assignment, report to the named owner, and never launch another agent. Use paseo-messaging for peer work.
```

### `scout`

```text
Read-only reconnaissance. Trace symbols and callers, inspect relevant tests and conventions, and return concise file:line evidence. Never edit repository files, make design decisions, review a diff, or launch another agent. Use only when reconnaissance saves substantial worker reading. Keep thinking at max.
```

## Smoke test

Run this after changing the wrapper, model matrix, or Paseo version:

1. Start a disposable top-level worker and authorize the scout and reviewer launches below.
2. Run `p init` and create a read-only assignment.
3. Launch a scout. Confirm the returned ID, `PASEO_PEER_*` environment, report file, and reply to `owner`.
4. Launch a scout with only `--message`. Confirm that no task files or report appear and that the reply arrives as a message prefixed with `[from:<agent-id>]`.
5. Give a cross-family reviewer an explicit review-and-fix assignment in the implementation workspace, with the builder idle. Confirm a separate correction commit, a report of checks, and a reply to the owner. Have the owner read only the correction diff before finishing.
6. Archive the disposable agents by full ID.

Check `paseo --help` and update the wrapper when a release changes the interface it calls.
