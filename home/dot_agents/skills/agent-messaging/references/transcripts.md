# Transcript lookup

The JSONL logs are the only record of what an agent actually received. Use them to confirm delivery after every send, and whenever bounded `zmx history` cannot answer a question about older turns. Match sessions by recorded cwd instead of guessing filenames or directory encodings.

Both lookups below run `fd`, which behaves the same on macOS and Ubuntu. `fd` errors on a search path that does not exist and has no flag to silence it, so guard the directory first.

Find Claude Code logs for the current cwd:

```sh
dir="$HOME/.claude/projects"
[ -d "$dir" ] && fd -e jsonl -t f . "$dir" -X jq -rn 'inputs | select(.cwd == $cwd) | input_filename' --arg cwd "$PWD" | sort -u
```

Find Codex logs for the current cwd:

```sh
dir="$HOME/.codex/sessions"
[ -d "$dir" ] && fd -e jsonl -t f . "$dir" -X jq -rn 'inputs | select(.type=="session_meta" and .payload.cwd == $cwd) | input_filename' --arg cwd "$PWD" | sort -u
```

Put the path you picked in a variable, because the filters below read one transcript at a time:

```sh
transcript=/absolute/path/to/session.jsonl
```

Claude Code records turns under `type` and `message`. Most user events are tool results, so keep text content only:

```sh
jq -r 'select(.type=="user" or .type=="assistant") | .message.content | if type=="string" then . else (map(select(.type=="text").text) | join("\n")) end | select(. != "")' "$transcript" | tail -20
```

Codex records messages as `response_item` payloads:

```sh
jq -r 'select(.type=="response_item") | .payload | select(.type=="message") | "\(.role): \([.content[]?.text // empty] | join("\n"))"' "$transcript" | tail -20
```

Drop the Codex `select(.type=="message")` filter only when tool calls matter. Keep every read bounded. Sort timestamped Codex rollout filenames rather than relying on an `ls -t` alias, and avoid non-portable `stat` flags.
