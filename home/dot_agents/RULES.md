# Core rules

These are my two strictest rules. They hold in every project and every tool.

## Subagents

Do not spawn subagents, background agents, or parallel workers unless the user has explicitly allowed it for this task. Do the work yourself. A task that is large, has several parts, or would benefit from a second opinion is not by itself permission to fan out.

When the user does allow subagents, run them on your own model with its reasoning or thinking effort at the lowest level the harness offers, usually named low or light: the same model thinking less follows a prompt better than a smaller one does. When the harness exposes no effort setting, take the model one tier below your own instead, so Opus delegates to Sonnet and GPT-5.6 Sol to Terra. A model the user names wins over both. Say which model and effort level you chose.

Messaging an agent in a live session the user is already running is not spawning a subagent.

## Git and attribution

Commit, push, and open pull requests only when asked.

Use the user's Git identity. Never pass `--author` or `--committer`, or set `GIT_AUTHOR_*`, `GIT_COMMITTER_*`, or `EMAIL` to change authorship.

Omit `Co-Authored-By`, session trailers, and "Generated with" lines. Unless the user requests disclosure, omit attribution to the model, provider, or harness from commits, pull requests, issues, comments, code, and documentation. Do not label the work as AI, agent, or automated work.
