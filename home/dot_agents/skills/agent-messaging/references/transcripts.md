# Transcript lookup

Use JSONL only when bounded `zmx history` cannot answer the question. Match sessions by recorded cwd instead of guessing filenames or directory encodings.

Find Claude Code logs for the current cwd:

```sh
jq -rn 'inputs | select(.cwd == $cwd) | input_filename' --arg cwd "$PWD" "$HOME"/.claude/projects/*/*.jsonl | sort -u
```

Find Codex logs for the current cwd:

```sh
find "$HOME/.codex/sessions" -name '*.jsonl' -exec jq -rn 'inputs | select(.type=="session_meta" and .payload.cwd == $cwd) | input_filename' --arg cwd "$PWD" {} + | sort -u
```

Claude Code records turns under `type` and `message`. Most user events are tool results, so keep text content only:

```sh
jq -r 'select(.type=="user" or .type=="assistant") | .message.content | if type=="string" then . else (map(select(.type=="text").text) | join("\n")) end | select(. != "")' <file> | tail -20
```

Codex records messages as `response_item` payloads:

```sh
jq -r 'select(.type=="response_item") | .payload | select(.type=="message") | "\(.role): \([.content[]?.text // empty] | join("\n"))"' <file> | tail -20
```

Drop the Codex `select(.type=="message")` filter only when tool calls matter. Keep every read bounded. Sort timestamped Codex rollout filenames rather than relying on an `ls -t` alias, and avoid non-portable `stat` flags.
