#!/usr/bin/env bash
set -euo pipefail

modifier=${1:-home/private_dot_paseo/modify_private_config.json}

configured=$(printf '%s\n' '{"version":3,"daemon":{"appendSystemPrompt":"old","mcp":{"other":true}},"keep":"value"}' | sh "$modifier")
jq -e '
    .version == 3
    and .daemon.mcp.enabled == true
    and .daemon.mcp.injectIntoAgents == false
    and .daemon.mcp.other == true
    and (.daemon | has("appendSystemPrompt") | not)
    and .keep == "value"
    ' <<<"$configured" >/dev/null

empty=$(sh "$modifier" </dev/null)
jq -e '
    .version == 1
    and .daemon.mcp.enabled == true
    and .daemon.mcp.injectIntoAgents == false
    and (.daemon | has("appendSystemPrompt") | not)
    ' <<<"$empty" >/dev/null
