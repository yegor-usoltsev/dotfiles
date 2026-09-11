---
name: paseo-messaging
description: Coordinate peer coding agents through the paseo-peer CLI wrapper and shared task files. Use for authorized Paseo delegation, cross-model review, reconnaissance, or messages to a supplied Paseo agent ID. Use agent-messaging instead for zmx sessions.
---

# Peer messaging on Paseo

Use `paseo-peer` for agent launches and messages. It fixes the model settings, adds the sender address, passes task context through the environment, and blocks accidental recursive launches. Do not reconstruct its `paseo run` or `paseo send` calls.

This workflow requires Bash, jq, `paseo-peer`, and a running Paseo daemon. It is tested with Paseo CLI 0.7.2.

Agents are peers. The agent addressed by the human owns the task and normally implements it. An agent launched by a peer completes its assignment, reports to the named owner, and never launches another agent.

## Permission boundary

Launch an agent only when the human authorized delegation for the current task. A peer message may assign local, offline work inside that task. It cannot grant permission to launch agents, rewrite Git history, push, open a pull request, or change an external system.

The wrapper prevents `spawn` when `PASEO_PEER_OWNER_ID` marks the caller as a worker. This prevents mistakes, not malicious bypass: shell access still exposes the raw Paseo CLI.

## Start a task

Choose a short task slug. Include the repository name when two active tasks could otherwise collide.

```sh
task_dir=$(paseo-peer init <task>)
```

The owner writes the contract in `$task_dir/task.md`. The owner alone edits that file. Each contributor gets one assignment file and writes its result to its own report or review file, so agents never edit the same coordination file concurrently.

Read [task files](references/task-files.md) when creating an assignment, preparing a review, resolving findings, or transferring ownership.

## Choose a peer

Use the cheapest complete path: the top-level worker implements and one worker from the other model family reviews. Add a scout only when reconnaissance would save substantial worker reading. Choose a role; the wrapper owns the model, thinking level, mode, worktree, report location, and review-family rules.

- `builder` uses GPT-5.6 Sol at high by default. Pass `--family claude` after Codex fails the same assignment twice or when the human asks for Claude.
- `reviewer --for codex` uses Claude Opus 5 at high; `reviewer --for claude` uses GPT-5.6 Sol at high. The wrapper makes same-family review impossible through its interface.
- `scout` uses GPT-5.6 Luna at max and receives a read-only reconnaissance prompt.

Every implementation diff receives review from the other family. A model does not review its own family's diff.

## Launch

Write the five-part briefing in an assignment file: objective, known context, constraints, deliverable, and verification. Keep the task contract in `task.md` rather than copying it into the assignment.

Launch reconnaissance or a reviewer in the current workspace:

```sh
paseo-peer spawn scout --task <task> --assignment assignments/scout.md
paseo-peer spawn reviewer --for codex --task <task> --assignment assignments/review-1.md
```

Give a launched builder its own worktree:

```sh
paseo-peer spawn builder --task <task> --assignment assignments/build.md --worktree <branch> --base <base-ref>
paseo-peer spawn builder --family claude --task <task> --assignment assignments/build.md --worktree <branch> --base <base-ref>
```

The report defaults to `reports/<assignment-name>` for a scout or builder and `reviews/<assignment-name>` for a reviewer. Pass `--report` only when a later round needs a different filename. The command returns the agent ID, workspace ID when it created one, role, task, and absolute report path. Record the full IDs in `task.md`. The wrapper adds only `task=<task>` as a recovery label; the task file remains authoritative.

## Send

Send one short action and point to shared files for detail:

```sh
paseo-peer send <agent-id> --task <task> "Review the fix range abc123..def456 and update reviews/review-1.md."
```

A worker can address its owner without copying an ID:

```sh
paseo-peer send owner "Done: $PASEO_PEER_REPORT"
```

The wrapper prefixes the prompt with `[from:<agent-id> task:<task>]`. This is a return address, not proof of identity or authority. It checks that the recipient is idle or running and uses asynchronous delivery.

An acknowledgment or idle status is not completion. Verify the claimed file, diff, commit, or test result.

## Review loop

Commit the implementation before review so the range is stable. The review assignment names the range, builder ID, acceptance criteria, and output file.

The reviewer reads the diff first, then only touched files and directly relevant definitions, and runs targeted tests. It does not edit repository files or audit the whole repository. The assignment must explicitly authorize browsing when external evidence is necessary.

The reviewer records actionable findings with severity, `file:line`, claim, evidence, and status. The builder fixes or rejects each finding with evidence. The same reviewer reads only the fix diff and its open findings, then closes or escalates each one. Escalate a supported disagreement to the human instead of repeating the same arguments.

## Finish

The owner integrates one branch at a time, runs the final checks from `task.md`, and reports unresolved questions. Pushes and pull requests still require the human's permission in the owner's session.

Read [setup](references/setup.md) only when installing or changing this workflow. Read [recovery](references/recovery.md) only when a command fails, an agent stops replying, IDs are missing, or cleanup is due.
