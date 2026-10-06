---
name: retro
description: Retrospective on an agent session to improve instructions, skills and checks.
disable-model-invocation: true
---

# Retro

Find the session the user names, or default to the current one: the Paseo timeline (`paseo logs <agent-id>`, agent records under `~/.paseo/agents/`), Claude transcripts under `~/.claude/projects/`, or Codex sessions under `~/.codex/sessions/`. Read the user's messages and the failures first; skim tool output.

Look for where the session lost time or quality:

- **Corrections:** the user repeated an instruction or reversed the agent. Is a rule missing, too weak or buried?
- **Questions:** the agent asked what it could have looked up or decided.
- **Navigation:** the agent searched long for a fact that a one-line pointer in `AGENTS.md` would give.
- **Checks:** a mistake a linter, test or CI job could catch. Prefer adding the check to adding a rule.
- **Coordination:** duplicate agents, idle waits, polling, lost messages, peers replaced instead of resumed.
- **Cost:** expensive tool calls, oversized outputs, or skills loaded for nothing.
- **No-ops:** instructions that changed nothing.

Present the findings worst first, each with its evidence and the concrete edit (file and text):

```text
1. Correction, session eb26080e: the agent started implementing before the user reviewed the plan they asked for ("I did not give you permission to start working").
   Edit: global AGENTS.md, Implementation: "When I ask to review a plan first, present it and end the turn; implement only after I approve."
```

Apply the edits the user approves with the `writing-for-agents` skill, and record the rest in the backlog.
