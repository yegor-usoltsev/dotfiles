---
name: review-loop
description: Review code or get it reviewed. Use when asked to review a diff, branch, commit range or pull request, for a second opinion or cross-review of your own change, or when review findings arrive, in any language. Your own change goes through a loop with a reviewer from the other provider until it approves.
---

# Review loop

Two modes:

- **Review:** someone asks you to review a change. Report findings and edit nothing; a request for review alone does not authorize edits.
- **Loop:** your own change needs review before it ships, or the user asks for one. A single reviewer from the other provider reviews it in rounds while you fix: Claude reviews Codex's work and Codex reviews Claude's. When that provider is out of limits or unavailable, use a fresh delegate of your own provider, whose context holds none of your reasoning, and say so in the report.

## Review

1. Pin what you review and confirm it is non-empty. For commits or a PR: `git log --oneline <base>..HEAD` and `git diff <base>...HEAD`. For uncommitted work: `git diff`, `git diff --cached` and the untracked files from `git status --short`.
2. Find the requirement (task, plan, issue or PR description) and the standards (`AGENTS.md`, linters, surrounding code).
3. Read the changed files in full and the callers they affect, not only the hunks. Stay read-only: no checkout, stash, reset or edits, because the author may share the tree.
4. Check the requirement (missing, partial or unrequested behavior) and the code (correctness, edge cases, error handling, concurrency, security, regression tests, needless complexity).
5. Run the checks that bear on a suspected defect; a demonstrated finding beats an argued one.
6. Report every defect, worst first, one per line with its location, effect and fix. Improvements that fix no defect go under `Optional`. When nothing turns up, say so and list what you checked.

```text
VERDICT: CHANGES
R1 blocker src/cart/totals.ts:42: the discount applies twice when a coupon and a promotion share a SKU, so orders undercharge. Apply discounts once per line.
R2 should src/auth/session.ts:88: the session token is logged at info level, so log readers can hijack sessions. Drop it from the log line.
R3 nit src/cart/totals.ts:97: the error names `items` instead of `lines`.
Checks: npm test -- cart (31 passed); reproduced R1 with a new case in totals.test.ts.
```

`blocker`: the intended case is wrong, or data loss or a security hole. `should`: a real bug callers will hit within the intent. `nit`: everything else, including other paths, rare cases, small costs and style.

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
Read the surrounding code and callers. Find bugs, broken callers and mismatches with the intent. Hold the change to its smallest form: flag code, tests or guards the intent does not need. Reply in the review-loop skill's format (VERDICT line, then one finding per line with a stable id and severity blocker, should or nit).
```

### Answer findings

Check each finding and its severity yourself.

- Agree: make the smallest fix. Prefer deleting or narrowing code over a new lock, cache, helper or option. Add one focused test that fails without the fix when the intent needs it.
- Disagree: say why with evidence (file:line, test, output).
- Nit or out of scope: decline in one line and list it as a follow-up.

Keep a ledger of each id, its severity and outcome. Rerun the checks. If review grew the diff, cut first. Do not agree just to end the loop.

### Next round

Start a new delegate only while a blocker or should stays open, or behavior changed since the last approval. Send the round 1 brief, the ledger (`fixed:`, `disagree:`, `declined:` with evidence) and the change since the last round, and ask it to check only the open ids and the changed code.

The budget is three rounds; extend to five only for security, permissions, data loss or concurrency findings that stay open with evidence, or when the user asks. Stop early when a round returns only nits.

### Stop

Done: the reviewer approves the current diff and no blocker, should or concern of your own remains. Stuck: an item stays disputed after two replies, or the budget runs out; show both sides in two or three lines each and let the user decide. A timeout, an error or the end of the budget is not approval.

Report the rounds, the reviewer's provider and model, what changed, the diff size before and after, and the fixed and declined findings with reasons. Push only when the user asked for it.

## Receiving findings

Verify each finding against the code before changing anything. Fix the confirmed ones, rerun the affected checks and commit. Answer the rest with evidence, such as the line that already handles the case or the test that proves it.
