---
name: workflow
description: Carry a software feature or fix through implementation, cross-family review, verification, documentation, and committed follow-up work. Use when the user invokes this skill by name, including /workflow or $workflow, or requests the full implementation, cross-family review, and delivery cycle. Do not select it merely for CI workflows, GitHub Actions, a standalone question, or read-only review.
---

# Feature workflow

Own the requested outcome through implementation, review, and local delivery. Load the linked skills at their handoffs instead of loading every skill up front. Repository instructions and the user's task-specific constraints still apply.

## Authorization

An explicit request to follow this workflow authorizes scoped peer delegation for implementation and cross-family review, local commits, relevant documentation and project-knowledge updates, and recording and committing deferred work. Automatic skill selection alone does not authorize peer delegation or supply the explicit persistence requests required by learn and backlog. Ordinary local edits and commits remain authorized by the user’s global rules. If delegation has not been authorized, complete independent local work and ask before launching a peer.

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

Assign review and correction to the other model family: Claude reviews and fixes Codex implementation, and Codex reviews and fixes Claude implementation. This is an implementation assignment under clean-code; use read-only review only when the user requests it. Carry acceptance criteria and recorded checks into the handoff, including browser scenarios and the code state they verified. Identify the implementing agent by its available return address; a separately launched builder is not required.

For Paseo, [paseo-messaging](../paseo-messaging/SKILL.md) owns the review-and-fix procedure, workspace ownership, reports, waiting and recovery, correction commits, integration, and check reuse. Follow that procedure without adding a second full review by default.

For a user-named zmx session, use [zmx-messaging](../zmx-messaging/SKILL.md) for delivery and verification. Put the explicit review-and-fix assignment in a shared file: stable diff range, repository path and branch, implementing and return session addresses, report path, acceptance criteria, and recorded checks. Confirm the reviewer is from the other family and can access the implementation checkout. Stop editing the assigned code and end the turn after handing it over. The reviewer corrects and simplifies within scope, runs affected checks, commits corrections separately, writes the report, returns its path, and stops editing. The owner reads the correction diff and checks it against requirements; another full review needs a concrete reason. Use the transport skill’s diagnostic guidance if delivery or completion fails.

Do not defer a defect required for acceptance to make the review pass. Return questions requiring new product behavior, wider scope, or changed constraints before making those changes. Escalate supported unresolved disagreements to the user. Record unrelated work through the backlog handoff below. Complete outstanding checks and rerun affected checks after code or environment changes, including affected browser scenarios; reuse unchanged evidence. Report unresolved defects or missing review as incomplete work.

## Preserve the result

Update relevant documentation to describe the final behavior. Use [writing-for-humans](../writing-for-humans/SKILL.md) for documentation, README files, reports, PR descriptions, and commit messages; use [humanizer](../humanizer/SKILL.md) as the final pass over substantial human-facing prose.

Use [learn](../learn/SKILL.md) to evaluate verified, durable project knowledge and update the appropriate project `AGENTS.md`, keeping `CLAUDE.md` linked as it prescribes. Explicit invocation of this workflow requests both this persistence and its local commit, so do not ask for additional end-of-session or commit approval. Save only findings that qualify; do not manufacture a lesson for every feature. Use [writing-for-agents](../writing-for-agents/SKILL.md) when writing agent instructions or updating a relevant repository-owned skill. Keep project knowledge in `AGENTS.md`; change a skill only for a verified reusable procedure within the task. Do not change applied global instructions or skills unless explicitly asked.

Use [backlog](../backlog/SKILL.md) for real unresolved work outside the current acceptance criteria. List and deduplicate existing items, preserve the evidence and the open decision, and archive completed items as prescribed. For an explicitly invoked workflow, the user requests recording these items on the current task branch and committing them; this supplies the branch-write and commit approval that backlog otherwise asks for. Commit deferred items separately from unrelated implementation work, stage exact paths, and use `[CI SKIP]` only when the repository's CI honors it. Do not put a current blocker into the backlog as a substitute for resolving or reporting it.

Commit the remaining task documentation and knowledge updates. Check the final diff and working-tree status so intended work is accounted for and unrelated work remains untouched. Report the outcome, local commits, actual verification and review results, saved follow-ups and their branch, and any remaining blocker. Stop before unauthorized external actions.
