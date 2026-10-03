---
name: paseo-peers
description: Coordinate substantial engineering work in Paseo as equal Claude and Codex peers: select configured worker profiles, assign file ownership, implement and cross-review, and communicate through peer.send. Use for delegation, pairing and peer review; handle small or conversational tasks alone and use scouts only for bounded read-only reconnaissance.
---

# Peers on Paseo

Every non-trivial task runs as two equal peers from different model families: one Claude agent and one Codex agent. They work autonomously, in parallel, talk to each other directly, review each other's work and settle problems between themselves, the way two senior colleagues would. The [paseo](../paseo/SKILL.md) skill describes the tools and CLI used below.

This applies inside Paseo, where `PASEO_AGENT_ID` is set. Outside Paseo, use the harness's native subagents when available; choose another model family only if the harness exposes it, and preserve the same file ownership rules.

## Start the counterpart

The agent the user started owns the task: it answers to the user and delivers the result. The counterpart is an equal in every engineering decision.

1. Call `list_profiles` and pick the counterpart's profile from the other family: `worker-codex` for a Claude owner, `worker-claude` for a Codex owner. A model the user named takes precedence.
2. Choose the shape (below) and, for a split, create the workspaces first.
3. Call `create_agent` with the profile materialized into `provider` and `settings`. Brief the counterpart in `initialPrompt`: the objective, what you already know, the constraints and checks, the shape and who does what, your agent ID (`$PASEO_AGENT_ID`) so it can message you, and that it should use this skill.

Do small, single-file or purely conversational work alone; a counterpart costs time.

## Choose a shape

**Pair** when the change is coupled or needs one line of thought. Both peers share one workspace. One writes the code; the other reviews it as it lands, reading `git diff` and the files, and sends corrections through `peer.send` while the writer is still working. Swap roles when it helps. Only the writer edits files; the reviewer edits only after the writer hands over.

**Split** when the work divides into parts with little overlap. Create one worktree workspace per part (`create_workspace` with `isolation: "worktree"`, `mode: "branch-off"`, an explicit `baseBranch`), and place each peer in its own. Each peer implements and commits its part independently. When both are done, each reviews the other's commits and fixes what it finds in separate commits. The owner then integrates both branches.

## Talk

Use `peer.send` for every message to another agent; it never interrupts the recipient. Reply to the ID in a message's `[from:…]` line.

Send a message when it carries something the other peer needs: a decision, a finding, a review comment, a question, a handoff or a finished result with its commit and checks. Skip acknowledgments and progress narration. Before editing a file the other peer owns, say so and wait for its answer.

Do not poll. A child you created with `create_agent` notifies you when it finishes; a peer's message wakes you. Keep doing independent work while you wait, and end your turn when the next step depends on the other peer.

## Review

Review the other peer's diff against the task's requirements, not your own preferences. In a pair, send corrections to the writer. After a handoff or in the split cross-review, fix defects directly and commit the fixes separately, then tell the author what changed. Verify claims by reading the code and running the checks; a message saying "done" is not evidence.

## Bring in help

Either peer can start a `scout` agent with `create_agent` for read-only exploration that would otherwise cost substantial reading; ask it for file:line evidence. Start other specialised agents the same way when a narrow job is easier to hand off. Archive helpers you started once their result is used.

## Heal without the user

Resolve problems between the peers before involving the user:

- A disagreement: each side states its evidence once. The peer who owns that part of the work decides; in a pair, the writer decides.
- A merge conflict or broken build: the peer whose change caused it fixes it; if unclear, the owner does.
- A peer that stops responding: check it with `get_agent_activity` or `paseo logs <agent-id>`. Cancel a stuck turn with `cancel_agent` and send it a fresh instruction. Archive an agent that is beyond repair, then start a replacement with a brief that includes the work done so far.
- A peer that stopped on a usage limit continues by itself after the reset. Do not replace it; carry on with your own part.

Ask the user only for a product decision, a change of scope, credentials or an action outside this computer, or a disagreement the peers could not settle.

## Finish

The owner runs the final checks on the integrated result, archives the agents and workspaces it created once their work is merged, and reports to the user what changed, how it was verified and anything left open.
