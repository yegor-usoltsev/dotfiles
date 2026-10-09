# Plan file

This format lets the `plan-loop` skill run a goal task by task across sessions and fresh implementers. Keep it in the persistent location from the global rules: the repository's plans folder when it has one, otherwise `~/dev/artifacts/plans/<repo>-<slug>.md`.

Write the smallest plan that lets a fresh agent continue: the goal and what done means, the commands that validate it, and tasks small enough for one implementer each, with checkable outcomes. Update it as decisions change; the checkboxes and `Decisions` are the shared state.

```markdown
# Goal: retry transient S3 upload failures; done when CI uploads survive injected 503s

## Validation
- `npm test`
- `npm run lint`

### Task 1: retry policy
- [ ] uploadFile retries 503 and network errors up to 3 times with exponential backoff
- [ ] 4xx errors fail at once; tests cover both

### Task 2: configuration
- [ ] STORAGE_RETRY_MS overrides the base delay; README documents it

## Decisions
- Task 1: reused src/lib/retry.ts; the SDK retry option cannot filter by status.
```

When the user asked to review the plan, present it with its path and end the turn; start implementing only after they approve.
