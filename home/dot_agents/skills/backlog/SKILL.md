---
name: backlog
description: Keep a repository's deferred work as one Markdown file per item under .backlog/. Use when the user mentions the backlog, when work surfaces that is real but outside the current task, or when picking what to do next in the repository.
---

# Backlog

`.backlog/` at a repository root holds work that is real but not being done now: a defect the current change did not introduce, drift with no visible symptom, a fix whose blast radius exceeded its value, an idea worth keeping. One file per item, plain Markdown, managed with a shell and standard tools.

The path is fixed, so every invocation in a repository reads the same store. The backlog belongs to the repository owner. Never post an item to a pull request, issue, or review thread unless the user asks for it.

Two modes cover the work. Read [Capture](#capture) when something worth keeping surfaces, and [Work an item](#work-an-item) when the user wants to pick up backlog work. Listing the backlog is the first step of both.

## Item format

An item lives at `.backlog/<slug>.md`. The slug names the work, not the file it touches, so `retry-loop-drops-the-last-error.md` reads correctly from a commit message and duplicates are a filename check away.

```markdown
---
worth: later
where: internal/queue/retry.go:88
added: 2026-09-07
---

# Retry loop drops the last error

The final attempt's error is overwritten by the loop variable, so a failing job reports the first failure instead of the one that exhausted the budget. Surfaced while adding queue metrics; the fix changes the error type, which is why it was deferred.
```

Three frontmatter fields:

- `worth: yes | later | no` orders the list. `yes` means the value is agreed and the work should happen; it says nothing about schedule. `later` means the value decision itself is open, and the body must name the unknown that would settle it. `no` records a decision not to fix, kept only while it still stops the next review from rediscovering the same thing.
- `where: path:line` anchors the item when it has one place. Omit it otherwise. The line drifts, so treat it as a hint and verify it before acting.
- `added: YYYY-MM-DD` is never updated, so the value reads as age. Zero-pad it so the files sort lexically.

The H1 is the title. The body has no required sections: give the reproduction, the constraint, the rejected approach, or a link, in whatever shape fits. A two-line item stays two lines. A `later` owes the unknown it waits on, and a `no` owes the rationale it exists to preserve.

## List the backlog

```sh
find .backlog -maxdepth 1 -name '*.md' | sort
find .backlog -maxdepth 1 -name '*.md' -exec grep -H '^worth:\|^added:' {} +
```

Report every item in one line each, `yes` first, then `later`, then `no`, oldest `added` first inside each group. Verify each `where` before reporting: if the file moved or the line no longer says what the item claims, report the item as stale rather than as ready work. Do not restate the item's reasoning; it is already in the file.

If `.backlog/` does not exist, say so and offer to start it. Do not create it empty.

## Capture

Record an item without being asked when work surfaces that is real, outside the current task, and would otherwise be lost. A finding the current change should fix is not a backlog item; fix it. A vague wish with no defect behind it is not one either. Everything below is a gate on that automatic write, not a reason to hand the decision back.

Check the branch before writing. An item dropped into someone else's feature branch either joins that diff or disappears with it.

```sh
git rev-parse --abbrev-ref origin/HEAD 2>/dev/null || git symbolic-ref -q --short refs/remotes/origin/HEAD
git branch --show-current
```

On the repository's default branch, write in place. Anywhere else, name the current branch and ask whether to write here anyway; on refusal, change nothing rather than switching branches or inventing a destination.

Dedupe before writing. The slug and the `where` path find the candidates, but the defect each item claims decides it. A shared file is not a duplicate. When the item already exists, say so and leave it alone; when the new sighting sharpens the description or changes the `worth` call, edit that file instead of adding a second one.

Create `.backlog/` when it does not exist, after the branch check and never before it. Write the file yourself once the item has passed those checks; capture is the one part of this skill that does not wait for an instruction, because an item nobody records is an item lost. Say which file you wrote. Committing is a separate decision: never commit without being asked, and when the user does ask, stage the exact paths this run created and commit them alone.

```sh
git add .backlog/retry-loop-drops-the-last-error.md
git commit -m "Add backlog item for the retry error loss [CI SKIP]"
```

A commit that touches only `.backlog/` ends with `[CI SKIP]`, because there is nothing for CI to build. Use the suffix only where the repository's CI honors it.

## Work an item

List the backlog first, then brief the item the user picks, or recommend one and let the user choose. Keep the briefing to a summary in your own words plus one line each for effort, blast radius, and materiality, each carrying the fact behind the judgement so the user can disagree with it. Judge the item against the repository as it stands now, not against its own account; the reasoning in the file goes stale the same way `where` does.

Take one item at a time. Reading the backlog is not permission to work it, so wait for the user to accept the item before changing code.

Implement the item under the repository's usual gates: tests, formatter, linter. Then archive it in the same commit as the fix, so the code change and the item's disposition never disagree.

```sh
mkdir -p .backlog/archive
git mv .backlog/retry-loop-drops-the-last-error.md .backlog/archive/
```

Add `done: YYYY-MM-DD` to the archived item's frontmatter, leaving the other fields as they were. That commit carries real code, so it takes no `[CI SKIP]` suffix.

Dropping an item is the same move with a different reason: archive it with `done` and a closing line in the body saying why it will not be done. When nobody needs the reasoning either, `git rm` the file instead and let the history hold it. A pure drop touches only `.backlog/`, so its commit takes the `[CI SKIP]` suffix.

## Rules

- Never commit an item alongside unrelated work.
- Never auto-commit. Ask, then stage explicit paths.
- Do not reopen an archived item. File a new one when the work comes back.
- Prefer deleting an item nobody will do and whose reasoning nobody needs over demoting it to `no`.
