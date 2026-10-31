---
name: flint
description: Track work in a Flint issue tracker and wiki with the flint CLI. Use when asked to find, create or update Flint issues (keys like ENG-12), comment on them, tick checklist items, attach files, name a branch for an issue, read and write Flint wiki pages, or manage Flint workspaces, projects, members, labels and API tokens. Also use in a repository that has a `.flint.json`, and whenever you record backlog work outside the current task.
---

# Flint

Flint is a self-hosted issue tracker with a Markdown wiki; the `flint` CLI does everything its UI does and prints JSON when piped.

Our Flint runs at https://flint.usoltsev.xyz and signs in through the Gitea at https://gitea.usoltsev.xyz, whose repositories, branches, commits and pull requests it links to issues. mise installs the `flint` CLI.

Write everything in Flint in Russian: issue titles and descriptions, comments, checklists and wiki pages. Code identifiers, commands and branch names stay as they are.

## Start here

This file is a discovery stub, not the usage guide. Before running other `flint` commands, load the guide from the CLI, which always matches the installed version:

```sh
flint skill
```

`flint <command> --help` lists the arguments and flags of each command. When a command reports that the CLI is not logged in, ask the user for an API key from Flint's **Settings → API keys** and run `flint login --url https://flint.usoltsev.xyz --token <key>`.

## Keep issues current

Flint never changes an issue by itself, so the issue reflects the work only when you update it.

- Fill in every property the project uses when you create or start an issue: status, assignee, priority and labels. Take the names from `flint project view` and `flint label list`, match how similar issues in the project are filled in, and do not invent labels.
- Move the issue with the work, using the project's status names:
  1. Starting: In Progress, assigned to the user you work for (`-a @me`), on a branch from `flint issue branch`.
  2. Pull request opened: In Review; the PR title starts with the key.
  3. Pull request merged: Done. Closed unmerged or dropped: Canceled, with a comment that says why.
- Before you hand off, view the issue and fix any property that no longer matches the work.

## Backlog

Record real work you find outside the current task as a Flint issue in the repository's project, deduplicated against open issues by the underlying problem, with the evidence and the open decision. Then return to the task.

- A repository without `.flint.json` has no linked project. Suggest creating the project or linking the repository, and record the item once the user decides.
- A repository with a local `.backlog/` directory or a similar file-based backlog: suggest migrating its items into Flint issues and deleting the files.
