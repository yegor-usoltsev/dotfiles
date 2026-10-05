---
name: pr
description: Write or update a pull request title and body.
---

# Pull request

Write for a reviewer who has not seen this conversation. Use the repository's PR template and title convention when it has them; otherwise write the title in its commit convention and use this body, with no preamble:

```markdown
## Summary

<what changes and why, in one or two sentences, then the smallest visual that makes it clear>

## Evidence

- **Before:** <failing test, output or screenshot>
- **After:** <passing test, output or screenshot>

## Merge danger

**Door:** <one-way or two-way>. **Blast radius:** <what a bad merge breaks>.

<only when material: what could break, for whom, and how to roll back>
```

## Summary

Pick one visual, two at most, and place it next to the sentence it supports: pseudocode for logic, an indented call tree for control flow, a shallow file tree with one comment per entry for a refactor or new module, a Mermaid sequence diagram for interaction between components, or a `diff` of any of these when the point is what changed. Keep only the calls, files and states that explain the change. For a tiny change, the sentence is enough.

## Evidence

Screenshots win for visual changes; test or command output is the default otherwise. Name the exact test that failed before and passes after. Use existing check results rather than inventing a failing run. Keep each claim to the command, scope and environment that produced it: a subset run does not prove the full suite passed. Mark results a colleague reported rather than ones you ran, and say plainly when no evidence was possible and why.

## Merge danger

A two-way door is cheap to roll back. A one-way door is not: migrations, deletes, published APIs or formats, external side effects. The blast radius names what a bad merge breaks, such as consumers, deploys, data or a single screen. A small reversible change needs no risk essay.

## Publish

Describe the final implementation, without conversation history or abandoned approaches. Writing the description does not authorize a push or PR; publish only with the user's permission, and pass a multi-line body through a file (`gh pr create --body-file`).
