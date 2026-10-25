---
name: flint
description: Track work in a Flint issue tracker and wiki with the flint CLI. Use when asked to find, create or update Flint issues (keys like ENG-12), comment on them, tick checklist items, attach files, name a branch for an issue, read and write Flint wiki pages, or manage Flint workspaces, projects, members, labels and API tokens. Also use in a repository that has a `.flint.json`.
---

# Flint

Flint is a self-hosted issue tracker with a Markdown wiki; the `flint` CLI does everything its UI does and prints JSON when piped.

Our Flint runs at https://flint.usoltsev.xyz and signs in through the Gitea at https://gitea.usoltsev.xyz, whose repositories, branches, commits and pull requests it links to issues. mise installs the `flint` CLI.

## Start here

This file is a discovery stub, not the usage guide. Before running other `flint` commands, load the guide from the CLI, which always matches the installed version:

```sh
flint skill
```

`flint <command> --help` lists the arguments and flags of each command. When a command reports that the CLI is not logged in, ask the user for an API key from Flint's **Settings → API keys** and run `flint login --url https://flint.usoltsev.xyz --token <key>`.
