---
name: writing-for-agents
description: Write instructions addressed to an agent rather than a person, above all Agent Skills. Use when creating a skill, turning a repeated workflow into one, editing a SKILL.md or its frontmatter, splitting or merging overlapping skills, deciding what belongs in SKILL.md versus references, validating a skill against the Agent Skills specification, or fixing when a skill triggers. Also use when writing a subagent or command prompt. For a project's own AGENTS.md, use learn; for prose a person will read, use writing-for-humans.
---

# Writing for agents

Write compact instructions that give a capable agent useful knowledge it would otherwise lack. Preserve the user's intent, scope, permissions, and target harnesses.

## Establish the capability

Start from real examples: a completed task, user corrections, existing runbooks, failure reports, code, or execution traces. Extract what worked before asking for more context. Ask only about missing information that would materially change the skill.

Identify:

- The user intents that should and should not activate the skill.
- The outcome and observable signs of success.
- Domain facts, tool procedures, edge cases, and conventions the agent cannot infer reliably.
- Required dependencies, compatibility limits, permissions, and stopping conditions.

Do not create a skill for generic knowledge a capable model already applies well. Give one skill one coherent capability. Merge skills when they serve the same intent and workflow; keep them separate when their triggers or procedures differ. Avoid alias skills that only redirect to another skill.

## Design for progressive disclosure

Treat context as finite. Each skill has three loading layers:

1. `name` and `description`, visible during skill selection.
2. `SKILL.md`, loaded when the skill activates.
3. Supporting resources, loaded or executed only when needed.

Keep shared purpose, routing, constraints, and the core procedure in `SKILL.md`. Put conditional detail in focused references and say exactly when to read each one. Use `scripts/` for repeated logic whose deterministic execution improves reliability, and test every new or changed script. Use `assets/` for templates or files copied into output, not for instructions.

Do not add empty directories, duplicated quick references, changelogs, setup guides, or process notes unless the skill's work requires them.

## Write the skill

Read [references/spec.md](references/spec.md) when creating or renaming a skill, changing frontmatter, or validating its structure.

- Name the directory and frontmatter identically with a short lowercase hyphenated name.
- Make the description state the capability and the user intent that should activate it. Put all trigger guidance there because the body is unavailable before activation.
- Write the body as direct instructions. Keep the desired outcome, non-obvious constraints, defaults, and decision criteria close to the step where they matter.
- Match control to fragility. Explain criteria for flexible work; prescribe exact commands or order only when deviation creates a concrete risk.
- Choose a default instead of presenting a menu of equivalent options. Mention an alternative only with the condition that makes it preferable.
- Teach a reusable procedure, not the answer to one example. Use examples only when they clarify an ambiguous format or decision.

Cross-link another skill only at a real handoff. Use a relative link and state which skill owns the next part so two skills do not govern the same behavior.

## Use high-value instruction patterns

Add a pattern only when the workflow benefits from it:

- A `Gotchas` section for facts that defy reasonable assumptions.
- A short template when output shape must be consistent.
- A checklist when dependent steps are easy to skip.
- A validation loop that runs a real checker, fixes failures, and repeats.
- A plan-validate-execute gate before batch or destructive operations.

Prefer concrete corrections over generic warnings. Explain why a constraint exists when that helps the agent generalize, but keep absolute language for safety, authorization, and invariants.

## Create or update

1. Inspect the target directory, related skills, callers, and relevant source material.
2. Define the trigger boundary and decide whether to create, merge, split, or retire a skill.
3. Plan only the resources that repeated use will justify.
4. Write or revise the smallest complete skill. Preserve an existing name unless the user requests a rename or the specification requires one.
5. Validate structure, links, commands, and any executable resources.
6. Exercise the skill on realistic tasks in proportion to its complexity and risk, then refine it from observed behavior.

When updating, replace stale guidance instead of appending another rule. Inspect every resource before deleting it, find its callers, and preserve unique behavior that still changes decisions. A user correction from one run becomes a general rule only when the underlying failure can recur.

## Validate and iterate

If `skills-ref` is installed, run the specification validator:

```sh
if command -v skills-ref >/dev/null 2>&1; then
  skills-ref validate ./skill-name
fi
```

Always check that the directory matches `name`, the description is within the specification limit, every relative link resolves, conditional references are discoverable, and `SKILL.md` stays below the recommended size. Read the complete result once to catch duplication, contradictions, placeholders, and instructions aimed at the wrong harness.

Test behavior, not exact wording. Use representative tasks and inspect execution traces when available. Compare against the prior skill or no-skill baseline only when the extra runs justify their cost. Let a human judge subjective output; use assertions for observable properties.

If activation is unreliable or the description changed substantially, read [references/descriptions.md](references/descriptions.md) and test its trigger boundary. Select revisions by held-out results rather than by the examples used to write them.

## Subagent and command prompts

A one-off prompt for a subagent or a slash command is not a skill: it is read once, it is never triggered by a description, and its reader cannot put a question to the user. Some harnesses route a reply back to you, and [agent-messaging](../agent-messaging/SKILL.md) does it over zmx, but the round trip costs a turn the agent may not have. Write the prompt so it needs no round trip, as a briefing with these parts, in this order:

1. **Objective.** What done looks like, in one sentence.
2. **Context.** The paths, findings, and decisions already made, stated as facts. Never make the agent rediscover what you already know.
3. **Constraints.** What not to touch, what to leave to the caller, and any convention the work must follow.
4. **Deliverable.** The exact shape of the answer you want back, since you cannot ask for a revision cheaply.
5. **Verification.** How the agent should check its own work before reporting, and what it must say when it could not check.

State the permission boundary explicitly. A subagent inherits neither your judgement nor the user's approvals, so name what it may change and require it to stop and report rather than act on anything destructive, external, or outside the stated scope. A read-only investigation should say so in the first line.

Ask for findings, not narration. A prompt that ends with "report file:line references and what you verified" gets a usable answer; one that ends with "let me know what you find" gets prose.

## Related skills

Use [learn](../learn/SKILL.md) for project instructions in `AGENTS.md`; this skill owns reusable skill packages and other agent-facing prompts. Use [writing-for-humans](../writing-for-humans/SKILL.md) only for human-facing documents bundled with a skill, not for instructions addressed to an agent.
