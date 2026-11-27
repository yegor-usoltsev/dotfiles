---
name: review-loop
description: Review code or get it reviewed. Use when asked to review a diff, branch, commit range or pull request, for a second opinion or cross-review of your own change, or when review findings arrive, in any language.
---

# Review loop

Two modes:

- **Review:** someone asks you to review a change. Report findings and edit nothing; a request for review alone does not authorize edits.
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

Keep a ledger of each id, its severity and outcome. Rerun the checks. When successive rounds expose the same failure class, stop fixing examples one by one. Revisit the underlying design and the smallest scope that meets the request. If that requires a scope decision or another round would repeat the same approach, hand back early with a recommendation.

### Next round

Start another pass only when a verified blocker or should remains to be checked after a fix or an evidence-backed response, or behavior changed since the last approval. For a delegate, send the round 1 brief, the ledger (`fixed:`, `disagree:`, `declined:` with evidence) and the change since the last round. Ask it to check only open findings and changed code.

### Review budget

Use at most three rounds per PR, or a stricter repository limit. Before a PR exists, the initial delegate review loop has its own three-round limit. Once the PR is open, its budget covers every review route; changing reviewers, starting a new thread or handing off does not start a new loop. Only the user can explicitly extend the budget. A request to finish or merge is not an extension.

Count the initial review of a candidate and each new pass, whether started by a push, a manual rerun or a delegate. Parallel reviews of the same candidate are one round; comment notifications, edits and duplicate verdicts are not new rounds. Record the round, head and verdict in the task handoff. On a wake-up or takeover, recover the count from PR review and check history and the prior handoff before starting more review work. If the count is uncertain, do not assume a fresh budget.

Check the budget before requesting a review or pushing a revision that would trigger one, including a base update. Do not work around a reviewer's configured pause or cap with a bot command, UI rerun, different reviewer or a replacement PR. A manual restart after a pause needs explicit user authorization even if the budget has not run out.

### Stop

Done: the reviewer approves the current diff and no blocker, should or concern of your own remains. Stop early if a finding stays disputed after two replies or the review cannot converge without a scope decision. If the budget runs out without approval, stop the review loop. If a PR exists, leave it open and unmerged and unwatch it in T3 before handing back. Report the count, current head and check state, verified blockers, and the recommended next step. A timeout, an error or the end of the budget is not approval.

Report the rounds, the reviewer's provider and model, what changed, the diff size before and after, and the fixed and declined findings with reasons. Commit and push only when the user or the invoking skill allows it.

## Receiving findings

Apply Answer findings and Review budget to hosted reviews, including bot comments and T3 notifications. Fix and commit only when you may edit the change; otherwise report the proposed fixes.
