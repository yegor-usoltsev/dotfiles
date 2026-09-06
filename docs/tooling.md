# Tool sources

[mise config](../home/dot_config/mise/config.toml.tmpl) defines shared CLI tools
and runtimes. [Package data](../home/.chezmoidata/packages.yaml) defines macOS
packages and applications. Linux system packages belong to Ansible's
`linux/cli-tools` role in the infrastructure repository.

| Profile | Machines | Tools |
| --- | --- | --- |
| `workstation` | macOS | Full development environment and desktop applications |
| `devbox` | Ubuntu development hosts | Same development CLI tools, without macOS applications |
| `server` | Small Ubuntu hosts | Shell, editor, Git, monitoring, file transfer and networking tools |

Servers do not install development toolchains, coding assistants, browser
downloads, media libraries, database clients or personal SSH private keys.
The common shell uses zsh, mise, starship, fzf and zoxide. Bash is a supported
fallback on Linux. Tool versions use `latest`, except Node LTS, Java Zulu 25
and stable Rust. The mise release delay is explicitly disabled.

## Package boundaries

Use mise for portable CLI binaries on both platforms. Homebrew and apt supply
bootstrap prerequisites, system integration, native libraries and tools without
a suitable portable release. In particular:

- `jq` comes from mise on every platform. Bootstrap installs and selects it
  before chezmoi runs, because the prerequisite hook and the `modify_` script
  for `.claude/settings.json` need it before the full tool set exists.
- `btop` uses Homebrew on macOS and mise on Linux.
- `ffmpeg`, ImageMagick, libvips and Graphviz are native development packages.
- PostgreSQL, MySQL and Redis clients use native packages. Homebrew's `libpq`
  and `mysql-client` binaries are added to the macOS login PATH.
- Homebrew `moreutils` provides `parallel`; GNU parallel is not installed there
  because its binary conflicts.
- Ubuntu's `yq` package is a different program from mise's mikefarah/yq.
- Keep Ubuntu's `htop` and `tmux` packages when required by `ubuntu-server`
  or Raspberry Pi metapackages. Removing them can break the platform baseline.

## mise backends

| Backend | Installation path |
| --- | --- |
| Registry aliases, `aqua:`, `github:` | Release binaries selected by mise |
| `npm:` | mise's embedded package manager; dependency builds enabled per tool |
| `pipx:` | uv, included in development profiles |
| `go:` | Go, included in development profiles |

The npm tools need current mise support for `allow_builds`; otherwise native
dependency installation can leave unusable launchers. The minimum mise version
guards this requirement. `github:userdocs/iperf3-static` explicitly maps the
Linux ARM64 asset name. On Linux ARM64, Playwright supplies Chromium because
Chrome for Testing has no build for that architecture. `update-browser`
refreshes the browser after tool upgrades. Ansible installs browser libraries
and grants its executable paths AppArmor user namespace access for sandboxing.

Zsh completions come from `misecompsync`, run by mise's `postinstall` hook. Its registry is built into the binary, so tools it does not know are added through a user registry merged over it. That file is at `~/Library/Application Support/mise-completions-sync/registry.toml` on macOS and `~/.local/share/mise-completions-sync/registry.toml` on Linux: the tool resolves it with the platform data directory, not with `XDG_DATA_HOME`. Keys are bare tool names, not mise backend identifiers. chezmoi and mise install themselves rather than through mise, so `.zshrc` generates their two completions into the zsh cache directory.

`~/.agents` is the source of truth for agent configuration: `AGENTS.md` and `skills` live there. Codex and Kimi read both paths natively, so only Claude needs symlinks, `~/.claude/CLAUDE.md` and `~/.claude/skills`. Codex additionally reads `$CODEX_HOME/AGENTS.md` when that variable is set, which nothing here sets, so `~/.codex/AGENTS.md` stays a symlink; `~/.codex/skills` holds only its own `.system` tree.

`~/.agents/skills` holds the shared skill set: agent-browser, doc-coauthoring, humanizer and humanizer-ru come from upstream archives, and `agent-messaging` is maintained here. `~/.claude/skills` is a symlink to it.

GitHub release downloads can exceed the unauthenticated API rate limit during
a full install. Provision a GitHub token through the local chezmoi secrets
file; interactive installs read it from Bitwarden. No repository access scopes
are needed for public downloads. Tokens and generated configuration remain
outside this repository.

Run `mise ls` to inspect installed versions and `mise registry <tool>` to see
the backend for an alias. Update the relevant package declaration when changing
ownership; avoid installing another copy through an unrelated package manager.
