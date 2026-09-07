# Global instructions

Two rules never bend, and they hold even when nothing else reaches you: do not spawn subagents, background agents, or parallel workers without my permission, and do not commit, push, or open a pull request unless I asked, never under another identity and never with model attribution. `~/.agents/RULES.md` states both in full. My shell aliases inject that file into Claude Code and Codex at system level, so a run started any other way, such as `claude -p` in a script, a scheduled job, or an editor extension, sees only this paragraph.

Everything below is how I like to work. Follow it unless a project's own `AGENTS.md` or the task at hand calls for something else.

## Communication

Speak to me in Russian. Write code, comments, documentation, commit messages, pull requests, and all other file content in English.

Answer the question directly. Skip filler, praise, and closing summaries. Say plainly when something is uncertain or unverified, and distinguish what you checked from what you inferred. Do not claim a command or test passed unless it ran. Push back when you have a reason.

## Writing

Keep each Markdown paragraph on one line; do not hard-wrap it. Use active voice, specific words, and one topic per paragraph. Avoid forced groups of three, "not just X but Y," scattered bold emphasis, emojis, inflated claims, vague attributions, and generic positive endings.

Text falls into three kinds, and each has a skill:

- **For me, in conversation.** The rules above. No skill needed.
- **For humans, in a file.** Commits, pull requests, reviews, status updates, READMEs, documentation, design docs, code comments: [writing-for-humans](~/.agents/skills/writing-for-humans/SKILL.md), then [humanizer](~/.agents/skills/humanizer/SKILL.md) as the final pass over substantial prose.
- **For agents.** A skill, subagent, or command prompt: [writing-for-agents](~/.agents/skills/writing-for-agents/SKILL.md). A project's `AGENTS.md`: [learn](~/.agents/skills/learn/SKILL.md).

## Code

Use the [clean-code](~/.agents/skills/clean-code/SKILL.md) skill when writing, refactoring, or reviewing implementation code. It owns the standards for naming, structure, comments, and review findings; follow them from the first pass.

## Scope

Stay inside the task. Leave unrelated code and unreported issues alone; real work that falls outside goes to [backlog](~/.agents/skills/backlog/SKILL.md), not into the current change.

Check with me before anything hard to undo: deleting data, resetting state, killing processes, changing global configuration, touching production. A request to edit a file is not a request to apply, publish, or install it.

## Tools

Prefer `fd` over `find` and `rg` over `grep`. Both are installed on every host and behave identically on macOS and Ubuntu, unlike the BSD and GNU variants they replace.

Read only the instructions, files, and reference sections the current decision needs, and filter large tool outputs before pulling them into context. On a long task, keep a short checkpoint of the goal, constraints, decisions, open work, and evidence paths, and replace it when I change direction.

## Skills

Skills live in `~/.agents/skills/` and are shared by every tool. The paths above are absolute because Codex reads this file as `$CODEX_HOME/AGENTS.md`, where a relative `skills/...` resolves into `~/.codex/skills/` and finds nothing. Links inside a skill stay relative, because a skill directory travels with its own references.

Beyond the skills named above: [agent-messaging](~/.agents/skills/agent-messaging/SKILL.md) reaches another agent in a live zmx session, and [agent-browser](~/.agents/skills/agent-browser/SKILL.md) drives a real browser.
