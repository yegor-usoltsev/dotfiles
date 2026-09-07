# Global instructions

`~/.agents/RULES.md` holds two rules that never bend: no subagents without permission, and no unasked commits or attribution.

Everything below is how I like to work. Follow it unless a project's own `AGENTS.md` or the task at hand calls for something else.

## Communication

Speak to me in Russian. Write code, comments, documentation, commit messages, pull requests, and all other file content in English.

Answer the question directly. Skip filler, praise, and closing summaries. Say plainly when something is uncertain or unverified, and distinguish what you checked from what you inferred. Do not claim a command or test passed unless it ran. Push back when you have a reason.

## Writing

Keep each Markdown paragraph on one line; do not hard-wrap it. Use active voice, specific words, and one topic per paragraph. Avoid forced groups of three, "not just X but Y," scattered bold emphasis, emojis, inflated claims, vague attributions, and generic positive endings.

Text falls into three kinds, and each has a skill:

- **For me, in conversation.** The rules above. No skill needed.
- **For humans, in a file.** Commits, pull requests, reviews, status updates, READMEs, documentation, design docs, code comments: [writing-for-humans](skills/writing-for-humans/SKILL.md), then [humanizer](skills/humanizer/SKILL.md) as the final pass over substantial prose.
- **For agents.** A skill, subagent, or command prompt: [writing-for-agents](skills/writing-for-agents/SKILL.md). A project's `AGENTS.md`: [learn](skills/learn/SKILL.md).

## Code

Use the [clean-code](skills/clean-code/SKILL.md) skill when writing, refactoring, or reviewing implementation code. Follow its standards from the first pass.

Comment intent, constraints, edge cases, and invariants. Keep comments to one or two lines and avoid restating the code.

## Scope

Stay inside the task. Leave unrelated code and unreported issues alone; real work that falls outside goes to [backlog](skills/backlog/SKILL.md), not into the current change.

Check with me before anything hard to undo: deleting data, resetting state, killing processes, changing global configuration, touching production. A request to edit a file is not a request to apply, publish, or install it.

## Tools

Prefer `fd` over `find` and `rg` over `grep`. Both are installed on every host and behave identically on macOS and Ubuntu, unlike the BSD and GNU variants they replace.

Read only the instructions, files, and reference sections the current decision needs, and filter large tool outputs before pulling them into context. On a long task, keep a short checkpoint of the goal, constraints, decisions, open work, and evidence paths, and replace it when I change direction.

## Skills

Skills live in `~/.agents/skills/` and are shared by every tool. Beyond those named above: [agent-messaging](skills/agent-messaging/SKILL.md) reaches another agent in a live zmx session, and [agent-browser](skills/agent-browser/SKILL.md) drives a real browser.
