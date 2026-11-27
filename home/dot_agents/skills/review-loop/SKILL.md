---
name: review-loop
description: Review code or get it reviewed. Use when asked to review a diff, branch, commit range or pull request, for a second opinion or cross-review of your own change, or when review findings arrive, in any language.
---

# Review loop

Two modes:

- **Review:** someone asks you to review a change. Report findings and edit nothing. An explicit one-shot review is allowed even after a loop stops; it does not restart the loop or authorize edits.
- **Loop:** the user, or a skill such as autopilot, asks for review of your own change. A single reviewer from the other provider reviews it in rounds while you fix: Claude reviews Codex's work and Codex reviews Claude's. When that provider is out of limits or unavailable, use a fresh delegate of your own provider, whose context holds none of your reasoning, and say so in the report.

## Review

1. Pin what you review and confirm it is non-empty. For commits or a PR: `git log --oneline <base>..HEAD` and `git diff <base>...HEAD`. For uncommitted work: `git diff`, `git diff --cached` and the untracked files from `git status --short`.
2. Find the requirement (task, plan, issue or PR description) and the standards (`AGENTS.md`, linters, surrounding code).
3. Read the changed files in full and the callers they affect, not only the hunks. Stay read-only: no checkout, stash, reset or edits, because the author may share the tree.
4. Check the requirement (missing, partial or unrequested behavior) and the code (correctness, edge cases, error handling, concurrency, security, regression tests, needless complexity).
5. Run the checks that bear on a suspected defect, keeping reproductions outside the checkout; a demonstrated finding beats an argued one.
6. Report every defect, worst first, one per line with its location, effect and fix. Improvements that fix no defect go under `Optional`. When nothing turns up, say so and list what you checked.

```text
VERDICT: CHANGES
R1 blocker src/cart/totals.ts:42: the discount applies twice when a coupon and a promotion share a SKU, so orders undercharge. Apply discounts once per line.
R2 should src/auth/session.ts:88: the session token is logged at info level, so log readers can hijack sessions. Drop it from the log line.
R3 nit src/cart/totals.ts:97: the error names `items` instead of `lines`.
Checks: npm test -- cart (31 passed); reproduced R1 with a scratch script in /tmp.
```

`blocker`: the intended case is wrong, or data loss or a security hole, however rare. `should`: a real bug callers will hit within the intent. `nit`: everything else, including style, small costs and unsupported hypothetical cases. Use `VERDICT: APPROVE` when no blocker or should remains; nits do not block approval.

## Loop

### Scope

Run `git status --short`. Leave unrelated changes alone and limit the review to this change's paths when they separate cleanly; otherwise ask. Find the base after `git fetch`: the PR's base branch, otherwise `git merge-base HEAD origin/<default-branch>`. Use the same diff command every round. Run the covering checks first and fix what they catch; do not send code the change breaks.

### Start the reviewer

In T3 Code, call `orchestrator_capabilities`, pick the other provider's strongest current model, and start one `delegate_task` with `role: "review"`. Elsewhere use the harness's subagent tool. One reviewer only; it must not start its own. Do not edit the scoped files while it runs, and wait for its result instead of polling.

Round 1 brief; the delegate has no history:

```text
Review only. Do not edit, commit, push, comment on PRs or start agents.
Repo: <path> Base: <sha> Intent: <one or two sentences> Out of scope: <what is not part of this change> Checks: <commands and results>
Diff: git diff <base> [-- <paths>]; also read untracked files from git status --short.
Read the surrounding code and callers. Find bugs, broken callers and mismatches with the intent. Hold the change to its smallest form: flag code, tests or guards the intent does not need. Reply with `VERDICT: APPROVE` (no blocker or should remains; nits allowed) or `VERDICT: CHANGES`, then one finding per line: `<id> <blocker|should|nit> <file:line>: <effect>. <fix>`, then the checks you ran.
```

### Answer findings

Check each finding and its severity yourself.

- Agree: make the smallest fix. Prefer deleting or narrowing code over a new lock, cache, helper or option. Add one focused test that fails without the fix when the intent needs it.
- Disagree: say why with evidence (file:line, test, output).
- Nit or out of scope: decline in one line; record only actionable out-of-scope defects as follow-ups.
- On a host thread, reply after the fix is pushed, cite the pushed SHA, and resolve only the threads you answered.

Keep a ledger of each id, its severity and outcome. Rerun the checks. If review grew the diff, cut first. Do not agree just to end the loop. When successive rounds expose the same failure class, revisit the design and the smallest scope that meets the request instead of patching examples one by one.

### Next round

Start another pass only when a verified blocker or should remains to be checked after a fix or an evidence-backed response, or behavior changed since the last approval. For a delegate, send the round 1 brief, the ledger (`fixed:`, `disagree:`, `declined:` with evidence) and the change since the last round. Ask it to check only open findings and changed code.

### Review budget

An autonomous review-and-fix loop has at most three rounds, or a stricter repository limit. Count the initial pre-PR loop separately. Once the PR is open, count the first pass (including an automatic review on opening) and all subsequent passes against a single PR budget. Changing reviewers, threads or owners does not reset it. Only the user can explicitly extend the limit; a request to finish or merge is not an extension.

Count each new pass started by a push, manual rerun or delegate. Parallel reviews of the same head count as one round; wait for active reviewers and address their findings together before pushing fixes. Notifications, comment edits and duplicate verdicts do not count. Record the round, head and verdict in the turn summary or handoff. Recover the count from that record and PR review and check history on wake-up or takeover. If you cannot establish that budget remains, hand back.

Check the budget before requesting a review or making any push that would trigger one, including CI fixes and base updates. Do not work around a reviewer's pause or cap with a bot command, UI rerun, different reviewer or replacement PR. A manual restart after a pause needs explicit user authorization even if budget remains.

### Stop

Review passes when the current head has a completed review, no verified blocker or should remains, and required approvals are met. A bot can pass without an `APPROVED` label, but a green check alone is not a verdict. A reviewer skipped by design is not expected; a pause, unexpected skip, timeout or error is not approval.

Stop without approval when an expected reviewer pauses or skips the head unexpectedly, a dispute persists after one evidence-backed reply and re-check, progress requires a scope decision, or another round is needed but not allowed. Whenever review stops without approval, leave any PR open and unmerged, unwatch it in T3, and report the count, head, check state, verified blockers and recommendation.

Report the rounds, the reviewer's provider and model, what changed, the diff size before and after, and the fixed and declined findings with reasons. Commit and push only when the user or the invoking skill allows it.

## Receiving findings

Apply Answer findings, Review budget and Stop to hosted reviews, including bot comments and T3 notifications. Fix and commit only when you may edit the change; otherwise report the proposed fixes.
