---
name: review
description: Review a diff, branch, commit range or pull request, or act on review findings. Use when asked to review, when cross-reviewing another agent's commits, or when findings arrive from a reviewer.
---

# Review

## As the reviewer

1. Pin what you review and confirm it is non-empty. For commits or a PR: `git log --oneline <base>..HEAD` and `git diff <base>...HEAD`. For uncommitted work: `git diff`, `git diff --cached` and the relevant files from `git status --short`, untracked ones included.
2. Find the requirement (task brief, plan, issue or PR description) and the standards (`AGENTS.md`, linters, the surrounding code).
3. Read the changed files in full and the callers they affect, not only the hunks. Stay read-only: no checkout, stash, reset or edits, because other agents may share the tree.
4. Check two axes separately:
   - **Requirement:** missing or partial behavior, behavior nobody asked for, and code that looks right but does the wrong thing.
   - **Code:** correctness (edge cases, error handling, concurrency, resources), security, tests that would catch a regression, and needless complexity (pass-through layers, speculative options, dead fallbacks, duplication).
5. Run the checks that bear on a suspected defect; a finding you can demonstrate beats one you can only argue.
6. Report every defect you find, worst first, one per line. The receiver filters; a reviewer who keeps only the severe ones hides real bugs.

```text
critical src/auth/session.ts:88: the session token is logged at info level. Anyone with log access can hijack sessions. Drop the token from the log line.
major src/cart/totals.ts:42: the discount applies twice when a coupon and a promotion share a SKU. Orders undercharge by the discount. Apply discounts once per line after merging the rules.
minor src/cart/totals.ts:97: the validation error names `items` instead of `lines`. The message misleads whoever debugs it. Name the real parameter.

Optional:
- src/cart/totals.ts:120: sumLines duplicates lib/money.ts:sum; reuse it.

Checks: npm test -- cart (31 passed); reproduced the double discount with the new case in totals.test.ts.
```

Severity: **critical** for crashes, data loss and security holes; **major** for wrong behavior or a broken contract; **minor** for other defects. Improvements that fix no defect go under `Optional`. When nothing turns up, say `No defects found` and list what you checked. On a re-review, check the fixes and the findings left open.

## As the receiver

Verify each finding against the code before changing anything. Fix the confirmed ones, rerun the affected checks, and commit. Answer the rest with evidence, such as the line that already handles the case or the test that proves it. Ask about a finding you cannot interpret before fixing related ones.
