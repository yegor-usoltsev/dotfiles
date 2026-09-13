# Task files

Use one directory under `${PASEO_PEER_ROOT:-$HOME/paseo}/<task>/`. `p init <task>` creates `task.md` plus `assignments/`, `reports/`, and `reviews/`.

## Task contract

The owner alone edits `task.md`:

```markdown
# <task>

## Objective
Describe the observable outcome.

## Acceptance criteria
- [ ] Add checkable behavior.

## Constraints
Record permissions, scope exclusions, repository conventions, and compatibility requirements.

## Agents
| agent ID | role | model | workspace ID | branch | status |
| --- | --- | --- | --- | --- | --- |

## Decisions
Record decisions that another agent needs to understand, with short reasons.

## Work
Record assignments, dependencies, commit ranges, and owned output paths.

## Open questions
Keep only unresolved choices that need the human.
```

Use full agent and workspace IDs. Short IDs may become ambiguous.

## Assignment

Give each agent a separate file under `assignments/`. Write it as a briefing in this order:

1. `Objective`: one sentence defining done.
2. `Context`: relevant facts, paths, decisions, peer IDs, and diff range. Do not copy the task contract.
3. `Constraints`: permission boundary, files or systems outside scope, whether edits are allowed, and any review scope cap.
4. `Deliverable`: the exact report file, commit, or answer expected.
5. `Verification`: commands or observable checks, plus what to report when a check cannot run.

A read-only assignment says so in its first sentence. Name every peer the worker may need to contact.

## Contributor report

Each contributor owns one file under `reports/`. State the outcome first, then commits or changed paths, verification that ran, verification that did not run, and any blocker. Keep investigation evidence as `file:line` references.

## Review

Each reviewer owns one file under `reviews/`. Keep it short:

```markdown
# Review and fix of <base>..<head>

## Result
State whether the task is complete or blocked, and name the correction commit if any. For read-only review, state `pass`, `changes requested`, or `escalated`.

## Changes
Summarize corrections and relevant simplifications. Omit this section when no changes were needed.

## Verification
List commands, outcomes, and any checks that did not run. Identify the checked commit or code state. Omit passing logs.

## Unresolved
Describe remaining defects or questions with file:line references and evidence. Omit this section when nothing remains.
```

Do not maintain a findings table or a status history for corrected issues. A read-only assignment uses the same report structure but lists actionable findings instead of corrections. The owner records decisions that affect the task in `task.md`.

## Ownership transfer

Transfer ownership only when the human's task still authorizes the receiving agent to do the remaining local work. The current owner records the transfer in `task.md` and sends the successor the task path and all active agent IDs. A transfer does not grant permission for external changes, agent launches, history rewrites, pushes, or pull requests.
