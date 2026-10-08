# Briefs

Fill each field from the current task and drop the ones it does not need. A junior gets the decisions made for it: name the approach, the files and the done condition, and have it ask rather than choose when the brief does not settle something. Point to files and commits rather than pasting the conversation or a large diff. Each example is a complete `initialPrompt`.

## Implementer

```text
Objective: add retry with backoff to the S3 upload in src/storage/upload.ts, because uploads fail on transient 503s in CI.
Context: the client is created in src/storage/client.ts; retries elsewhere use src/lib/retry.ts. Keep the public uploadFile signature.
Ownership: you are the only writer in this checkout until you report; edit src/storage/ and its tests. I stay read-only here meanwhile.
Expected result: uploadFile retries 503 and network errors up to 3 times; other errors fail at once.
Checks: npm test -- storage, npm run lint.
Commit each finished step. Decide judgment calls yourself and list them in your result.
Send the result to <your agent ID> with peer.send: commits, checks with results, decisions, open issues.
```

## Reviewer

```text
Review: commits a1b2c3d..HEAD on branch fix-upload in this checkout, against the brief in docs/plans/upload-retry.md.
Use the review skill. Stay read-only: no checkout, stash, reset or edits, because the writer keeps working in this tree.
Send each finding to <your agent ID> with peer.send as soon as you confirm it, then a final message that ends with the review summary.
```

For live pairing, add: `Review each commit as it lands; treat unfinished work as context, and confirm a finding still holds at HEAD before sending it.`

## Exploration

```text
Question: which services still call the v1 /orders endpoint?
Sources: ~/dev/acme/*/src; HTTP client calls and config files only.
Read-only: no edits, service changes or new agents.
Return to <your agent ID> with peer.send: each caller as path:line with the call, plus anything you could not check.
```

## Replacement or handoff

```text
You replace agent <old agent ID>, which could not continue. Continue its task; the earlier conversation is not available to you.
Goal and plan: ~/dev/artifacts/plans/acme-pwa-parity.md (tasks 1-3 are ticked).
Done: commits 4d5e6f7 (offline cache) and 8a9b0c1 (install prompt) on branch pwa-parity; npm test passes at 8a9b0c1.
State: task 4 is half-done and uncommitted in src/sw/sync.ts; finish or rewrite it.
Next: task 4, then task 5. Decisions so far are under Decisions in the plan.
Report to <your agent ID> with peer.send when task 5 is committed or if you hit a blocker.
```
