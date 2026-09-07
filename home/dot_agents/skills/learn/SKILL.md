---
name: learn
description: Capture verified, reusable project knowledge in AGENTS.md and keep CLAUDE.md linked to it for Claude Code. Use when asked to learn, save project knowledge, update agent instructions, or retain durable findings from a significant work session.
---

# Learn project knowledge

Save durable instructions that will help Codex, Claude Code, and other agents make better decisions in this repository. `AGENTS.md` is canonical. A sibling `CLAUDE.md` should be a relative symlink to it so Claude reads the same instructions.

Do not edit global files under `~/.agents`, `~/.claude`, or `~/.codex` unless the user explicitly asks for a global change.

## What belongs

Capture verified project-specific knowledge such as:

- Architecture boundaries and data flow that are hard to infer from one file.
- Conventions repeated across the codebase.
- Required build, test, deployment, or debugging commands with non-obvious constraints.
- Integration behavior, operational invariants, and durable gotchas.

Exclude session history, the change just made, resolved incident details, temporary state, secrets, machine-specific preferences, generic engineering advice, and rules already supplied by a global instruction or skill. Put deferred work in the repository backlog instead of `AGENTS.md`.

A candidate earns space only when evidence supports it and a capable agent is likely to use it months later. Prefer a specific instruction over background narrative.

## Inspect before writing

Find the repository root and read the relevant `AGENTS.md`, `CLAUDE.md`, nested instruction files, README, and code that supports each candidate. Follow any existing memory-placement convention unless it conflicts with the user's current request.

Check symlinks with `test -L` and `readlink`, and inspect `git status` before changing files. Do not overwrite uncommitted instruction changes.

Use the nearest existing `AGENTS.md` whose scope fits the knowledge. Keep repository-wide rules at the root. Create a nested `AGENTS.md` and matching `CLAUDE.md` symlink only when the rule applies clearly to one subtree.

## Keep AGENTS.md canonical

When normalization is in scope:

- If `AGENTS.md` is a regular file and `CLAUDE.md` is absent, create `CLAUDE.md` as `ln -s AGENTS.md CLAUDE.md`.
- If only a regular `CLAUDE.md` exists, preserve its content in `AGENTS.md`, verify the copy, then replace `CLAUDE.md` with the relative symlink.
- If both are regular files, compare them, merge unique valid instructions into `AGENTS.md`, verify that no instruction was lost, then replace `CLAUDE.md` with the symlink.
- If either path is a broken link, points outside its directory, or contains conflicting uncommitted work, stop and ask before replacing it.

Do not duplicate content across the two files. A correct symlink needs no explanatory stub.

## Update the instructions

Review the session for candidates, then verify each one against the current repository. Deduplicate existing guidance and remove stale text only when the same evidence proves it obsolete.

If the user explicitly asked to save or learn the findings, edit the applicable `AGENTS.md` directly. If this skill runs as end-of-session hygiene without an explicit request to persist knowledge, show the exact candidate instructions and wait for confirmation. If nothing qualifies, report that there is no durable project knowledge to add.

Add the smallest useful text to an existing section when possible. Use direct instructions, concrete paths, and commands. Do not turn one failure into a universal rule without evidence.

Read the complete resulting instruction file, check it for duplication and contradictions, then run `git diff --check`. Commit only when the user has asked for a commit.
