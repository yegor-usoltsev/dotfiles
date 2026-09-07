---
name: agent-browser
description: Automate websites and Electron apps with agent-browser. Use for navigation, forms, screenshots, data extraction, authenticated flows, web app testing or QA, Slack or VS Code automation, and cloud browser sessions. Prefer it over built-in browser automation when available.
---

# agent-browser

Browser automation CLI that drives Chrome or Chromium over CDP, with accessibility-tree snapshots and compact `@eN` element refs.

Requires the `agent-browser` CLI and Chrome or Chromium. If the CLI is missing, ask before installing it globally with `npm i -g agent-browser && agent-browser install`.

## Start here

This file is a discovery stub, not the usage guide. Before running any `agent-browser` command, load the workflow content from the CLI, which always matches the installed version:

```bash
agent-browser skills get core             # workflows, common patterns, troubleshooting
agent-browser skills get core --full      # include the full command reference and templates
```

## Specialized skills

Load a specialized skill when the task falls outside browser web pages:

```bash
agent-browser skills get electron          # Electron desktop apps (VS Code, Slack, Discord, Figma, ...)
agent-browser skills get slack             # Slack workspace automation
agent-browser skills get dogfood           # Exploratory testing / QA / bug hunts
agent-browser skills get derive-client     # Record a HAR, derive a standalone API client for a site
agent-browser skills get vercel-sandbox    # agent-browser inside Vercel Sandbox microVMs
agent-browser skills get protected-vercel-deployments  # Access protected Vercel deployments
agent-browser skills get agentcore         # AWS Bedrock AgentCore cloud browsers
```

Run `agent-browser skills list` to see everything available on the installed version.

## Gotchas

The upstream `agent-browser skills get core` output declares `allowed-tools` as a comma-separated list, which the Agent Skills specification does not accept. Do not copy that frontmatter into this file.

The observability dashboard runs on port 4848 independently of browser sessions, and also answers through a proxied URL such as `https://dashboard.agent-browser.localhost`. Stay on the dashboard origin: session tabs, status, and stream traffic are proxied internally, so session ports do not need to be exposed.
