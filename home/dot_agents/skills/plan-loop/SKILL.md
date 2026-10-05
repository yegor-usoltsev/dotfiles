---
name: plan-loop
description: Run a multi-step plan unattended in Paseo, one fresh worker per task, driven by a plan file and a heartbeat. Use when the user asks for a loop, a goal to pursue unattended, overnight work, or a plan to execute task by task.
---

# Plan loop

Each task runs in a fresh implementation worker with a small context. The plan file holds the state, and worker completions and a heartbeat wake you. You orchestrate: dispatch, verify and decide, while workers write the code.

## Plan

Use the user's plan if one exists; otherwise write one in the [plan](references/plan.md) format, in the persistent location it names.

## Each wake-up

Run these steps on start, on every heartbeat, and whenever a worker finishes:

1. A worker is still running or stopped on a usage limit: end the turn. It resumes by itself, and a message to it adds nothing.
2. The last worker finished: confirm from the plan and `git log` that its task is ticked and committed and that validation passes. Otherwise start a fresh worker for the same task with the failure output. After two failed attempts, leave the task unticked, record why under `Decisions`, and stop as in step 5, because later tasks may depend on it.
3. Unticked tasks remain: start a worker for the first one with the implementer brief from the `paseo` skill, plus the plan path, the task number and these rules: do this task only, run validation, tick its boxes, commit, record decisions and deviations under `Decisions`, and send a real blocker to you rather than to the user.
4. All tasks are ticked: ask a senior peer from another provider to review the whole branch with the `review` skill, give the findings to a worker to fix, and repeat until a round finds no critical or major defects, for at most three rounds.
5. Stop when the goal is met, when a task fails twice, or after three wake-ups without a new commit, which is a stalemate; record the cause in the plan. Either way, delete the heartbeat and send the user the final report: commits, validation, decisions, the unfinished task and open findings.

A finished turn or a green test run is not the goal; only the plan's done condition is.

## Heartbeat

Create it once the first worker runs: `create_heartbeat` with a stable name, a cadence matched to task length (every 20–30 minutes is typical), a `maxRuns` or `expiresIn` bound, and a prompt such as `Plan loop tick for <plan path>: run the plan-loop wake-up steps.`
