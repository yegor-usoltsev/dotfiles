---
name: workflow
description: Carry a software feature or fix through implementation, cross-family review, verification, documentation, and committed follow-up work. Use when the user asks to follow workflow, including /workflow or $workflow, or requests this complete development cycle. Do not use for a standalone question or read-only review.
---

# Feature workflow

Own the requested outcome through implementation, review, and local delivery. Load the linked skills at their handoffs instead of loading every skill up front. Repository instructions and the user's task-specific constraints still apply.

## Authorization

An explicit request to follow this workflow authorizes scoped peer delegation for implementation and cross-family review, local commits, relevant documentation and project-knowledge updates, and recording and committing deferred work. Automatic skill selection alone grants none of these permissions. If delegation has not been authorized, complete independent local work and ask before launching a peer.

Only the agent talking directly to the user may launch peers. Peers may exchange scoped work but may not launch further agents. Keep local work inside the task and preserve unrelated changes. Never rewrite Git history, push, open a pull request, deploy, or mutate any external system without the user's explicit authorization for that action. Use the user's Git identity and omit model attribution and co-author trailers.

## Establish the task

Read the relevant project instructions, inspect the working tree, and identify the expected behavior, acceptance criteria, constraints, and checks. Resolve ordinary implementation choices yourself; ask only about missing decisions that materially affect the outcome. Read existing code and tests before choosing a design.

Use [paseo-messaging](../paseo-messaging/SKILL.md) for peer coordination by default. Create its task contract and follow its role selection and worktree rules. Use [zmx-messaging](../zmx-messaging/SKILL.md) when the user names a live zmx session or requests that transport. If the required transport or review family is unavailable, report the limitation instead of silently omitting review or launching through an improvised path.

The owner normally implements; one peer from the other model family reviews and fixes. Add builders or reconnaissance only when they save substantial work. Use [writing-for-agents](../writing-for-agents/SKILL.md) for assignments and substantial handoffs. Give each peer a bounded objective, known context, constraints, deliverable, and verification requirements.

## Implement and verify

Apply [clean-code](../clean-code/SKILL.md) from the first edit. Reuse repository patterns, keep the design simple, and fix defects within the task. Before review, inspect the diff for unnecessary code, duplication, and abstractions whose cost exceeds their benefit. Shorten code where doing so improves clarity; do not compress it at the expense of readability.

Run the relevant tests, formatter, linter, and build checks required by the project. Cover changed behavior and meaningful boundaries without tests that merely repeat the implementation. For a web feature, use [agent-browser](../agent-browser/SKILL.md) to exercise the affected user flow in a local or explicitly authorized test environment. Report checks that could not run and the reason; never treat them as passed. Browser testing does not authorize writes to production or other external systems.

## Review and resolve

Commit the implementation to provide a stable review range. Follow [writing-for-humans](../writing-for-humans/SKILL.md) for short, concrete commit messages and other human-facing artifacts. Follow the repository's commit convention and stage only the intended paths.

Assign review and correction to the other model family: Claude reviews and fixes Codex implementation, and Codex reviews and fixes Claude implementation. This is an implementation assignment under clean-code; use read-only review only when the user requests it. Name the stable diff range, implementation workspace, builder ID, report path, and checks already run in the assignment. Scope the work to the diff, directly relevant code, acceptance criteria, and targeted checks.

Confirm the builder has stopped editing, then hand the implementation workspace to the reviewer using the transport skill's procedure. The sender stops work on the task and ends its turn until the reviewer returns the result. The reviewer fixes errors and simplifies changed code, touching adjacent code only when a correction needs it. Preserve requirements and avoid rewrites based only on preference. Run affected checks, commit corrections separately, report the result and any unresolved questions, and stop editing. Do not send fixable findings back as work for the builder.

The owner reads the correction diff and checks the result against the requirements. Do not commission another full review by default; follow up only for a concrete defect or supported disagreement. Return questions that require new product behavior, wider scope, or changed constraints before making those changes, and escalate unresolved disagreements to the user. Do not defer a defect required for acceptance to make the review pass. Record unrelated work through the backlog handoff below.

Integrate delegated changes one branch at a time without rewriting history. Run outstanding checks and rerun affected checks after corrections or integration changes. Reuse recorded results when the code and relevant environment are unchanged; a change of agent alone does not require another run. Report unresolved defects or missing review as incomplete work.

## Preserve the result

Update relevant documentation to describe the final behavior. Use [writing-for-humans](../writing-for-humans/SKILL.md) for documentation, README files, reports, PR descriptions, and commit messages; use [humanizer](../humanizer/SKILL.md) as the final pass over substantial human-facing prose.

Use [learn](../learn/SKILL.md) to evaluate verified, durable project knowledge and update the appropriate project `AGENTS.md`, keeping `CLAUDE.md` linked as it prescribes. Explicit invocation of this workflow requests this persistence, so do not ask for an additional end-of-session approval. Save only findings that qualify; do not manufacture a lesson for every feature. Use [writing-for-agents](../writing-for-agents/SKILL.md) when writing agent instructions or updating a relevant repository-owned skill. Keep project knowledge in `AGENTS.md`; change a skill only for a verified reusable procedure within the task. Do not change applied global instructions or skills unless explicitly asked.

Use [backlog](../backlog/SKILL.md) for real unresolved work outside the current acceptance criteria. List and deduplicate existing items, preserve the evidence and the open decision, and archive completed items as prescribed. For an explicitly invoked workflow, the user requests recording these items on the current task branch and committing them; this supplies the branch-write and commit approval that backlog otherwise asks for. Commit deferred items separately from unrelated implementation work, stage exact paths, and use `[CI SKIP]` only when the repository's CI honors it. Do not put a current blocker into the backlog as a substitute for resolving or reporting it.

Commit the remaining task documentation and knowledge updates. Check the final diff and working-tree status so intended work is accounted for and unrelated work remains untouched. Report the outcome, local commits, actual verification and review results, saved follow-ups, and any remaining blocker. Stop before unauthorized external actions.
