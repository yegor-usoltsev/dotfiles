---
name: retro
description: Retrospective on an agent session or thread to improve instructions, skills and checks. Use when the user asks for a retro, a retrospective, a post-mortem of a session, or what went wrong in a thread, in any language.
---

# Retro

Find the session the user names, or default to the current one. In T3 Code, read the thread with `t3_thread_read` and find others with `t3_thread_search`; outside it, read Claude transcripts under `~/.claude/projects/` or Codex sessions under `~/.codex/sessions/`. Read the user's messages and the failures first; skim tool output.

Look for where the session lost time or quality:

- **Corrections:** the user repeated an instruction or reversed the agent. Is a rule missing, too weak or buried?
- **Questions:** the agent asked what it could have looked up or decided.
- **Navigation:** the agent searched long for a fact that a one-line pointer in `AGENTS.md` would give.
- **Checks:** a mistake a linter, test or CI job could catch. Prefer adding the check to adding a rule.
- **Coordination:** duplicate delegates, idle waits, polling, lost results, reviewers restarted instead of resumed.
- **Cost:** expensive tool calls, oversized outputs, or skills loaded for nothing.
- **No-ops:** instructions that changed nothing.

Present the findings worst first, each with its evidence and the concrete edit (file and text):

```text
1. Correction, thread 7f3a: the agent started implementing before the user reviewed the plan they asked for ("I did not give you permission to start working").
   Edit: global AGENTS.md: "When I ask to review a plan first, present it and end the turn; implement only after I approve."
```

Write the least text that changes behavior: one owner per rule, the reason in a clause when it is not obvious, no emphasis words, and no rule the model already follows by default. Apply the edits the user approves, and record the rest with the `flint` skill.
