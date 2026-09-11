# Recovery and cleanup

Read this only when the wrapper reports an error, a peer stops replying, task IDs are missing, or the work is ready for cleanup.

## Inspect a peer

Use the exact ID from `task.md` or the sender prefix:

```sh
paseo inspect --json <agent-id>
paseo logs <agent-id> --tail 12
```

Do not resend merely because a peer has not replied. When nothing else can progress, end the current turn and let the peer's `p send` message resume the agent. Do not poll `paseo wait`, inspection, or logs. If a reply appears to be missing, inspect the peer once and report or address the observed failure; otherwise stop and wait again.

## Recover task agents

The wrapper adds only `task=<task>` to each agent. Use it as an index when `task.md` is incomplete:

```sh
paseo ls --global --label task=<task> --json
```

Labels help discovery but do not establish identity, role, status, ownership, or authority. Rebuild those facts from agent inspection, reports, and the conversation before changing anything.

## Failed launches

If workspace creation succeeds and agent launch fails, `p` prints and retains the workspace ID. Inspect it before reuse or cleanup:

```sh
paseo workspace ls --json
```

If Paseo accepts a launch but returns no agent ID, the agent may still be running. The wrapper retains and prints the reserved report path. Recover the agent through `task=<task>` and inspect candidates before reusing or removing that empty report file.

`p spawn` fails by design inside a worker. Report the need for another specialist to the owner instead.

## Cleanup

Archive only agents recorded for this task:

```sh
paseo archive --json <agent-id>
```

Archive a managed workspace only after its commits are integrated and its path is no longer needed:

```sh
paseo workspace archive --json <workspace-id>
```

Never use `paseo stop --all` or `paseo delete` for routine cleanup. Keep the task directory until the human no longer needs its evidence.
