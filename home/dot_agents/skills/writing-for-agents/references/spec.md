# Agent Skills format

This is a compact working reference for the [Agent Skills specification](https://agentskills.io/specification). Consult the upstream specification when exact or newer behavior matters.

## Directory layout

Each skill is a directory containing `SKILL.md`. Add other directories only when they support the workflow:

```text
skill-name/
|-- SKILL.md
|-- scripts/       optional executable helpers
|-- references/    optional documentation loaded on demand
`-- assets/        optional files used in generated output
```

Other files and directories are allowed. These names are conventions, not an exhaustive allowlist.

## SKILL.md

`SKILL.md` starts with YAML frontmatter and continues with Markdown instructions.

| Field | Required | Constraint |
| --- | --- | --- |
| `name` | yes | 1-64 characters; lowercase ASCII letters, digits, and hyphens |
| `description` | yes | 1-1024 characters; state what the skill does and when to use it |
| `license` | no | short license name or a reference to a bundled license file |
| `compatibility` | no | 1-500 characters describing environment requirements |
| `metadata` | no | string-to-string mapping for client-specific metadata |
| `allowed-tools` | no | experimental space-separated list of pre-approved tools |

The `name` must match its parent directory, must not start or end with a hyphen, and must not contain consecutive hyphens.

Minimal frontmatter:

```yaml
---
name: example-skill
description: Perform a specific capability. Use when the user asks for its corresponding outcome.
---
```

Client support for optional fields can vary. Omit an optional field unless it carries useful information for the target environments.

## Context and references

Clients normally discover a skill from its name and description, then load the full body only after activation. The specification recommends keeping `SKILL.md` below 500 lines and 5,000 tokens.

Keep reference files focused and load them only when their details apply. Link resources with paths relative to the skill root:

```markdown
Read [the API guide](references/api.md) when the task calls the external API.

Run `scripts/validate.py` after generating the configuration.
```

Keep references one level from `SKILL.md` where practical. Avoid chains in which one reference is the only way to discover another.

## Validation

Run `skills-ref validate ./skill-name` when the reference validator is installed. It checks structural rules, not whether the instructions improve agent behavior.

Also inspect the final skill for broken relative links, stale or duplicated guidance, unused resources, unfinished placeholders, untested scripts, and dependencies missing from `compatibility` or the body.
