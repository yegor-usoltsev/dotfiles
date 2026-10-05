---
name: paseo
description: Coordinate agents in Paseo. Use before create_agent or create_workspace, when pairing with a peer or splitting work across worktrees, recovering a stuck agent, or setting up a heartbeat or schedule; also for Paseo CLI, workspace script and plugin questions.
---

# Paseo

The Paseo system prompt holds the always-on rules: roles, peer.send, waiting, usage limits. This skill covers the moves that need more than a rule. MCP tool schemas and `paseo <command> --help` document arguments; [tools](references/tools.md) holds the non-obvious semantics of workspaces, scripts, heartbeats, schedules and plugins.

## Decide whether to delegate

Do the work yourself when it fits in a handful of tool calls or needs this conversation's context. Delegate a sizeable, separable track: an independent review, a part of a split, a long investigation, or a lookup a scout can answer while you keep working. Check `list_agents` for a colleague already on this task first.

## Start an agent

1. Call `list_profiles` and pick by the role in each profile's notes: a senior peer from another provider for pairing or independent review, an implementation worker for scoped coding or deep investigation, a scout for a narrow lookup with an easily checked answer. A profile or model the user named wins; an unqualified "ask Claude" or "ask Codex" means that provider's senior.
2. Materialize the profile, since `create_agent` has no profile parameter: `provider: "<provider>/<model>"`, `modeId` → `settings.modeId`, `thinkingOptionId` → `settings.thinkingOptionId`, `featureValues` → `settings.features`. Omit absent values.
3. Brief it in `initialPrompt` with the [briefs](references/briefs.md) template for its role: the objective and why it matters, what you already know, what it owns, the expected result, the checks, and your agent ID. Pass small context in the brief; write a long handoff to a file under the persistent location from the global rules and pass the path.
4. Leave `workspaceId` out to share your workspace, and leave `notifyOnFinish` on so its completion wakes you.

## Pair or split

**Pair** for coupled work that needs one line of thought. Both seniors share a workspace; one writes and commits small steps, the other reviews each step from `git diff` as it lands and sends findings with `peer.send` while the writer keeps going. Swap roles at natural boundaries with an explicit handoff; only the current writer edits.

**Split** for parts with little overlap. Each extra writer gets its own worktree workspace (`create_workspace` with `isolation: "worktree"`, `mode: "branch-off"` and an explicit `baseBranch`), commits its part there, and then reviews the other part with the `review` skill. The owner merges the branches, runs the final checks, and archives the extra workspaces.

Message formats for findings, handoffs and results are in [messages](references/messages.md).

## Recover

- A quiet agent is usually on a usage limit and resumes by itself. Look with `get_agent_activity` or `paseo logs <id>` only when you are blocked on it.
- A stuck turn: `cancel_agent`, then a fresh scoped instruction through `peer.send`.
- An agent beyond repair: archive it and start a replacement with the replacement brief, which carries the finished commits and the next step.
- A merge conflict or broken build: the agent whose change caused it fixes it; when that is unclear, the owner does.
- A disagreement: each side states its evidence once; the owner of that part decides, and in a pair the writer decides. Bring it to the user only when it changes the product outcome or scope.

## Finish

The owner verifies the integrated result, archives the helpers and workspaces it created once their work is merged or saved, and sends the final report.

For an unattended multi-step plan, use the `plan-loop` skill.
