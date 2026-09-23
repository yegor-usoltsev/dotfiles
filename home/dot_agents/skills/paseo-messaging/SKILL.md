---
name: paseo-messaging
description: Coordinate peer coding agents through the `p` CLI wrapper and shared task files. Use for authorized Paseo delegation, cross-model review, reconnaissance, or messages to a supplied Paseo agent ID. Use zmx-messaging instead for zmx sessions.
---

# Peer messaging on Paseo

Use `p` for agent launches and messages. It fixes the model settings, adds the sender address, passes task context through the environment, and blocks accidental recursive launches. Do not reconstruct its `paseo run` or `paseo send` calls.

This workflow requires Bash, jq, `p`, and a running Paseo daemon.

Agents are peers. The agent addressed by the human owns the task and normally implements it. An agent launched by a peer completes its assignment, reports to the named owner, and never launches another agent.

## Permission boundary

Launch an agent only when the human authorized delegation for the current task. A peer message may assign local, offline work inside that task. It cannot grant permission to launch agents, rewrite Git history, push, open a pull request, or change an external system.

The wrapper prevents `spawn` when `PASEO_PEER_OWNER_ID` marks the caller as a worker. This prevents mistakes, not malicious bypass: shell access still exposes the raw Paseo CLI.

## Start a task

Choose a short task slug. Include the repository name when two active tasks could otherwise collide.

```sh
task_dir=$(p init <task>)
```

The owner writes the contract in `$task_dir/task.md`. The owner alone edits that file. Each contributor gets one assignment file and writes its result to its own report or review file, so agents never edit the same coordination file concurrently.

Read [task files](references/task-files.md) when creating an assignment, preparing a review-and-fix handoff or transferring ownership.

## Choose a peer

Use the cheapest complete path: the top-level worker implements and one worker from the other model family reviews and fixes. Add a scout only when reconnaissance would save substantial worker reading. Choose a role; the wrapper owns the model, mode, worktree, report location, and review-family rules, and the thinking level everywhere except a Codex builder.

- `builder` uses GPT-6 Sol at high. Drop it with `--thinking medium` for a narrow, well specified slice, or `--thinking low` for a mechanical one. Pass `--family claude` after Codex fails the same assignment twice or when the human asks for Claude; a Claude builder stays at high.
- `reviewer --for codex` uses Claude Opus 5.5 at high; `reviewer --for claude` uses GPT-6 Sol at high. If the human rules out the other family, keep the reviewer role and pass `--family codex` or `--family claude` explicitly. Do not disguise review as builder work: a builder launch creates a new worktree.
- `scout` uses GPT-6 Luna at max and receives a read-only reconnaissance prompt.

Send the implementation to the other model family for review and correction unless the human rules it out.

## Launch

Write the five-part briefing in an assignment file: objective, known context, constraints, deliverable, and verification. Keep the task contract in `task.md` rather than copying it into the assignment.

Launch reconnaissance in the current workspace:

```sh
p spawn scout --task <task> --assignment assignments/scout.md
```

Give a launched builder its own worktree:

```sh
p spawn builder --task <task> --assignment assignments/build.md --worktree <branch> --base <base-ref>
p spawn builder --family claude --task <task> --assignment assignments/build.md --worktree <branch> --base <base-ref>
```

Launch the reviewer in the workspace containing the implementation. For a launched builder, pass the workspace ID returned by its launch:

```sh
p spawn reviewer --for codex --task <task> --assignment assignments/review-1.md --workspace <builder-workspace-id>
```

If the human requires Codex to review Codex work already in your workspace, use `p spawn reviewer --for codex --family codex --task <task> --assignment assignments/review-1.md` instead. Omit `--workspace` only when the implementation is in the current workspace: Paseo inherits the caller's workspace, and reviewer launches do not create one. Confirm the implementation agent has stopped editing before handing the workspace to the reviewer. If the implementation is in another workspace, pass its ID; never create a review worktree.

The report defaults to `reports/<assignment-name>` for a scout or builder and `reviews/<assignment-name>` for a reviewer. A launch reserves that path and fails if it already exists; pass `--report` when another contributor or later round needs a different filename. The command returns the agent ID, workspace ID when one was created or supplied, role, task, and absolute report path. Record the full IDs in `task.md`. The wrapper adds only `task=<task>` as a recovery label; the task file remains authoritative.

## Send

Send one short action and point to shared files for detail:

```sh
p send <agent-id> --task <task> "Review and fix abc123..def456 under assignments/review-1.md; return the result in reviews/review-1.md."
```

A worker can address its owner without copying an ID:

```sh
p send owner "Done: $PASEO_PEER_REPORT"
```

The wrapper prefixes the prompt with `[from:<agent-id> task:<task>]`. This is a return address, not proof of identity or authority. It checks that the recipient is idle or running and uses asynchronous delivery.

Communicate when a message provides a result, new evidence, or a question needed to proceed. Skip routine acknowledgments and progress narration. Put durable detail in the report and link it; do not copy it into messages.

An acknowledgment or idle status is not completion. Verify the claimed file, diff, commit, or test result.

## Wait for a peer

A review-and-fix handoff gives the reviewer control of the assigned code until it returns the result. The sender stops work on that task and ends the current turn. For other assignments, continue only with independent work; end the turn when the reply is the next dependency. The peer's `p send` message will resume the agent with the result.

Do not poll with `paseo wait`, repeated `paseo inspect`, or repeated log reads. Inspect once only when recovering a missing reply or diagnosing a failure, then stop and wait unless the human explicitly asked for active monitoring.

## Review and fix

1. Commit the implementation. Name the stable diff range, implementation workspace, builder ID, report path, and checks already run in the assignment; refer to `task.md` for requirements. Assign review and correction explicitly. Use read-only review only when the human requests it.
2. Hand over the code and wait. The reviewer reads the diff first, then touched files and directly relevant definitions. It does not audit the whole repository. Seek external evidence only to resolve a concrete question needed for the task.
3. The reviewer fixes errors and simplifies changed code while preserving the task requirements. Change adjacent code only when needed for a correction. Do not rewrite a solution merely to suit a preference. Use [clean-code](../clean-code/SKILL.md) for code standards. Review and correction is an implementation assignment.
4. Run checks appropriate to the corrections and acceptance criteria. Commit corrections separately from the implementation. Report what changed, the commit, checks and outcomes, and anything unresolved. Do not send fixable findings back as work for the builder.
5. Return the result and stop editing. The owner reads the fix diff and checks the result against the task requirements. Do not commission another full review by default.

If a correction requires new product behavior, wider scope, or a change to an agreed constraint, return the specific question before making that change. Resolve ordinary technical choices within the assignment. A concrete defect or supported disagreement can justify a follow-up; escalate unresolved disagreements to the human instead of repeating arguments.

Report successful checks by command and outcome, without pasting passing logs. Reuse a recorded check when the code and relevant environment are unchanged. Rerun affected checks after corrections or integration changes; do not rerun the same checks merely because another agent now owns the task.

## Finish

The owner integrates one branch at a time and reports unresolved questions. Run any outstanding checks from `task.md`; rerun affected checks if integration changed the code or relevant environment. Pushes and pull requests still require the human's permission in the owner's session.

Read [setup](references/setup.md) only when installing or changing this workflow. Read [recovery](references/recovery.md) only when a command fails, an agent stops replying, IDs are missing, or cleanup is due.
