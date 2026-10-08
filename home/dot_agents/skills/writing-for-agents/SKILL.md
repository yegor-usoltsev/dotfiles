---
name: writing-for-agents
description: Write or edit text that agents read. Use when creating or changing a skill, an AGENTS.md, a system prompt, profile notes, or a reusable brief template.
---

# Writing for agents

Every always-loaded line costs tokens and attention on every turn, and every extra document is one more thing to keep current. Start from an observed failure or a missing contract, and write the least text that changes behavior.

## Place

- **Global AGENTS.md:** durable preferences and permission boundaries every session needs.
- **Project AGENTS.md:** non-obvious conventions and constraints of one repository.
- **Paseo system prompt:** rules every Paseo agent needs and agents outside Paseo do not.
- **Skill:** a procedure needed only sometimes. The `description` is the trigger: name the action and each distinct case once, and leave out what the body says. Set `disable-model-invocation: true` (and, for Codex, `policy.allow_implicit_invocation: false` in `agents/openai.yaml`) only for skills the user starts by hand.
- **Reference file:** what only some paths through a skill need, such as templates and edge-case semantics, behind a one-line pointer that says when to read it.
- **Tool, check or config:** behavior a linter, test, hook or setting can enforce. Prefer it to a rule.

Own each rule in one place and link to it elsewhere. Leave commands and options where `--help`, tool schemas or the file itself state them; write down only the convention, the reason and the gotcha.

## Write

- Give ordered steps for procedures, each ending on a checkable state, such as "validation passes and the box is ticked".
- State the target behavior. A prohibition puts the unwanted behavior into context; keep one only as a hard boundary, paired with what to do instead.
- Give the reason in a clause when a rule is not self-evident; the model generalizes from it. Leave out capitals, MUST and "critical" emphasis, which current models over-apply.
- Leave out "double-check" and "verify your work" steps; extra self-verification instructions cause over-verification. Independent review by another agent is different and worth keeping.
- Say when not to do something expensive, such as delegating, asking the user or adding a process step, as well as when to do it.
- Show an example wherever a format is expected: a brief, a message, a finding, a report or a plan file.
- Use one precise word the model already knows (*owner*, *stalemate*, *junior*) instead of a sentence, and reuse it.
- Leave out profile names, model names, versions and dates; they go stale with every release and belong in config. Describe roles instead.
- Delete sentences the model already obeys by default and whole no-op rules, and preserve unique existing requirements.
- Check model-specific claims against the vendor's current prompting guide before turning them into rules.

## Test

When the user explicitly asks for a behavior comparison using additional agents, pick a small representative request and the observable result that should improve. Run it on a fresh junior twice, with the old text and with the new, under the same settings. Give it the request, minimal context and the permitted actions, and keep the expected answer out of its prompt. Inspect what it actually did, including needless questions, duplicate work and unverified claims. Keep the change only if behavior improved, and rerun after a model upgrade to delete rules that have become no-ops.
