---
name: retro
description: Retrospective on an agent session or thread to improve instructions, skills and checks. Use when the user asks for a retro or retrospective, or for a post-mortem or what went wrong in an agent session or thread, in any language.
---

# Retro

Find the session the user names, or default to the current one. In T3 Code, read the thread with `t3_thread_read` and find others with `t3_thread_search`; outside it, read Claude transcripts under `~/.claude/projects/` or Codex sessions under `~/.codex/sessions/`. Read the user's messages and the failures first; skim tool output. If the named session cannot be found, say so instead of using another.

Look for where the session lost time or quality:

- **Corrections:** the user repeated an instruction or reversed the agent. Is a rule missing, too weak or buried?
- **Questions:** the agent asked what it could have looked up or decided.
- **Navigation:** the agent searched long for a fact that a one-line pointer in `AGENTS.md` would give.
- **Checks:** a mistake a linter, test or CI job could catch. Prefer adding the check to adding a rule.
- **Coordination:** duplicate or unneeded delegates, idle waits, polling, lost results.
- **Cost:** expensive tool calls, oversized outputs, or skills loaded for nothing.
- **No-ops:** instructions that changed nothing.

Present the findings worst first, each with its evidence and the concrete edit (file and text):

```text
1. Navigation, thread 7f3a: the agent spent 14 tool calls finding where the deploy config lives.
   Edit: repo AGENTS.md: "Deploy settings live in ops/deploy.toml; scripts/deploy.sh only reads them."
```

Write the least text that changes behavior: one owner per rule, the reason in a clause when it is not obvious, no emphasis words, and no rule the model already follows by default. Search the existing rules first; when one already covers the case, fix its wording or placement instead of adding a copy.

Global rules and skills are sources in `~/dev/yegor-usoltsev/dotfiles/home/dot_agents/`, and the Flint guide lives in `~/dev/yegor-usoltsev/flint/cli/guide.md`; never edit `~/.agents`, which chezmoi overwrites. Present the findings and stop. Apply the edits the user approves; record approved work you cannot do now, such as a new check, with the `flint` skill.
