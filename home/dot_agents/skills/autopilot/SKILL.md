---
name: autopilot
description: Carry a change end to end without supervision, to a pull request ready for the user's merge or, when explicitly asked, through the merge. Use when the user says autopilot, full send, full stop, take it all the way, ship it, or asks to work autonomously while they are away, in any language.
---

# Autopilot

The user is not watching this thread. Your updates and final message go unread until long after you stop, so you own the work from its current state to the end state below.

## End state

- **PR mode** (default): stop with the PR ready for the user to merge. Never merge, enable auto-merge, enter a merge queue or push to the default branch.
- **Merge mode**: merge the PR yourself once the merge gate passes.

When the request does not make the end state clear, ask before starting work with the harness's question tool, recommending PR mode. If no answer is possible, use PR mode. The first line of your first message names the mode, for example `Autopilot, PR mode: I will stop with the PR ready for your merge.`

## Permissions

The request grants, for this task only:

- commits, pushes, rebases and `--force-with-lease` on this task's branch;
- opening the PR, and in merge mode merging it once the gate passes;
- the test methods the proof needs, even where a project file says to ask first: browser automation, simulators and devices, running the app or a dev server, screenshots. Rules about how to test still apply.

It does not cover production changes, data deletion, changes outside the repository, closing a PR, force-pushing another branch, or bypassing branch protection or a harness approval prompt.

## Steps

1. **Finish the change** with the smallest change that reaches the goal. Fix the case that happened, not every case that could. Create a branch first when you are on the default branch.
2. **Prove it.** Get proof for every change; see below.
3. **Review it** with the `review-loop` skill until the reviewer approves.
4. **Open the PR** with the `open-pr` skill after rebasing onto the latest default branch.
5. **Wait for CI and reviews.** In T3 Code, call `watch_pull_request` and end your turn; it wakes you when a check fails or passes, a review or comment arrives, or the branch conflicts, on GitHub and Gitea. Elsewhere, block on one command that ends when checks finish, such as `gh pr checks <n> --watch --fail-fast`. Never write your own polling loop. Act only on checks and comments newer than the latest push.
6. **Handle feedback.** Verify each bot or human finding against the code, fix the real ones with proof, and reply to the rest with a written reason. Keep the PR at the size the goal needs: decline unneeded tests, guards for edge cases that do not matter and extra compatibility, and list them as follow-ups. Rebase when the base branch moves under the PR's files.
7. **Finish at the gate.** In PR mode, hand off once the gate passes. In merge mode, merge with the repository's usual method (check recent merged PRs), and stay until the host reports the PR merged. In T3 Code, call `unwatch_pull_request` before a handoff or a question.
8. **Report:** the mode, the PR link, the final head or merge commit, your proof, the reviewer's verdict, the decisions you made and the remaining risks.

Stay active from step 1 to the end. Ending your turn without a watcher while checks are pending stops the work, because nobody will prompt you again.

## Proof

Proof is evidence you observed yourself in this session: command output, a reproduction, a screenshot. Use the most direct proof the change allows:

- Reproduce the original failure, apply the fix, and watch the same reproduction pass.
- Run the checks the repository's CI runs.
- Add one focused test that fails without the fix when the behavior has none and the repository has a test setup.
- For UI and runtime behavior, run the app and look at the change; green mocked tests do not prove the user experience works.

When you cannot prove a change, you do not have full confidence; ask the user.

## Merge gate

All of these hold on the latest commit:

- Your proof covers every change in the diff.
- Required checks are green.
- Review bots have finished, and each finding is fixed or answered with a written reason.
- No human review still requests changes.
- The branch is up to date with the default branch and the host reports it mergeable.

## Asking the user

A question in a normal message goes unseen and the thread looks finished. Ask with the harness's question tool, with all context in the question: the PR link, what blocks you, and the options with your recommendation first. Ask only when you cannot prove the change, the gate cannot pass and you cannot fix that, the next step is outside the permissions above, the goal is ambiguous in a way that changes the result, or another PR makes this one obsolete. Decide everything else yourself and list those decisions in the report. Without an answer, take the safe path: leave the PR open and unmerged and start the final message with the question.
