# dotfiles

Personal macOS and Ubuntu dotfiles managed with [chezmoi](https://chezmoi.io/). `README.md` covers installation and updates for people; this file covers what an agent needs to change the repository correctly.

## Source layout

`.chezmoiroot` points at `home`, so the source state is `home/` and the repository root holds nothing chezmoi applies. Two special files are the exception and stay at the root: `.chezmoiroot` itself, and `.chezmoiversion`, which chezmoi looks for anywhere in the source directory. Every other `.chezmoi*` file, `.chezmoi.toml.tmpl` included, resolves against the source state path and must live under `home/`.

Change the source state, never the applied target: `home/dot_zshrc.tmpl` is the file to edit, and `~/.zshrc` is its output.

Much of the source state sits in dot-prefixed directories: `home/.chezmoiscripts/`, `home/.chezmoidata/`, `home/.chezmoitemplates/`, `home/.chezmoihooks/`. `rg` and `fd` skip those unless you pass `--hidden`, so pass it when searching this repository.

Filenames carry chezmoi attributes. Each target type has its own prefix chain in a fixed order, so check [the attributes table](https://www.chezmoi.io/reference/source-state-attributes/) before renaming a source file rather than reasoning from another target type. Scripts are `run_`, then `once_` or `onchange_`, then `before_` or `after_`; `dot_` is always last on the types that allow it; `.tmpl` is the suffix. Scripts run in alphabetical order of the name with attributes stripped, which is what the numeric prefixes (`10-`, `20-`, `90-`) control.

When a path stops being managed, add its target path to `home/.chezmoiremove`. Deleting the source file alone leaves the old file sitting in the home directory.

## Profiles

`.profile` is `workstation` on macOS, and `server` or `devbox` on Linux; `home/.chezmoi.toml.tmpl` prompts for the Linux value and rejects anything else. `server` is the minimal profile, so almost every conditional in the source state reads `{{ if ne .profile "server" }}`.

`home/.chezmoiignore.tmpl` drops whole target trees per platform and profile. A new target that must not reach servers or must not reach one platform belongs there, not behind a template conditional that renders an empty file.

The `server` profile carries no compiled-language toolchains, coding assistants, browser downloads, media tools, database clients, `gh` or personal SSH private keys. It keeps Python and uv, because operational scripting and `pipx:` tools need both.

## Secrets

Templates read `.secrets.context7ApiKey`, `.secrets.githubToken`, `.secrets.sshPrivateKey` and `.secrets.sshPublicKey`. `home/.chezmoi.toml.tmpl` fills them from `~/.config/chezmoi/secrets.toml` when that file exists, and from Bitwarden through `rbw` otherwise. Every key defaults to an empty string, so a template that uses one must still render when it is empty. `home/.chezmoiignore.tmpl` is the place to skip a whole file in that case, as it does for `.config/mise/github_tokens.toml`.

Never commit a secret, a generated configuration file or a private key. The GitHub token exists only to lift the unauthenticated API rate limit during a full install and needs no repository scopes.

## Scripts

`home/.chezmoitemplates/script-header` sets `PATH` for Homebrew, `~/.local/bin` and the mise shims, includes the `log` template, and embeds the macOS build number or the distribution release so scripts rerun after an operating system upgrade. Every script under `home/.chezmoiscripts/` should include it. `home/.chezmoitemplates/log` alone gives `info`, `warn`, `success` and `error` to files that need no `PATH` changes, such as `home/dot_local/bin/executable_update.tmpl`.

A `run_once_` script runs only when its rendered content has not already completed successfully, so reverting to earlier content does not rerun it. To retrigger on a change elsewhere, embed a hash of what it depends on:

```
# config.toml hash: {{ includeTemplate "dot_config/mise/config.toml.tmpl" . | sha256sum }}
```

`home/.chezmoiscripts/run_once_after_10-mise.sh.tmpl` hashes both the mise config and the completion registry. Adding another input that must retrigger it means adding another hash line.

`home/.chezmoihooks/ensure-prerequisites.sh` runs before every source-state read and only checks prerequisites. Do not make it install or prompt: it also runs under non-interactive Ansible provisioning, where a prompt deadlocks the run. It demands an unlocked Bitwarden vault only when neither `~/.config/chezmoi/secrets.toml` nor `~/.config/chezmoi/chezmoi.toml` exists, so `chezmoi status` and `chezmoi diff` keep working on a configured machine.

Keep each file's existing shebang and portability target. Scripts under `home/.chezmoiscripts/` are bash, the `modify_` scripts declare `#!/bin/sh`, and `home/dot_config/shell/` is sourced by both bash and zsh. Indent with tabs. CI checks the zsh files with `zsh -n`, and everything else with `bash -n`, `shellcheck -s bash -e SC1090,SC1091` and `shfmt -d -i 0`.

## Adding a tool

Portable CLI binaries go in `home/dot_config/mise/config.toml.tmpl`. macOS packages and applications go in `home/.chezmoidata/packages.yaml`. Linux system packages belong to the `linux/cli-tools` role in the infrastructure repository, not here.

When adding a tool to the mise config:

1. Decide the profile. Wrap it in `{{ if ne .profile "server" }}` unless a server genuinely needs it.
2. Check whether misecompsync knows it. Its registry is compiled into the binary, and `home/.chezmoitemplates/mise-completions-registry` is a user overlay merged on top. A tool it does not know gets no zsh completions until you add an entry there.
3. Use the bare tool name as the registry key, not the mise backend identifier: `procs`, not `github:dalance/procs`.
4. Pick a backend. A bare registry alias resolves through mise, and `aqua:` or `github:` names a release directly when the alias is wrong or missing. `npm:` tools with native dependencies need `allow_builds = true`, which is what `min_version` guards; do not lower it. `pipx:` needs uv, which every profile has, so `pipx:httpie` sits outside the conditional; `go:` needs Go and therefore stays inside it.

The overlay template renders into two targets, because misecompsync resolves the platform data directory and ignores `XDG_DATA_HOME`: `~/Library/Application Support/mise-completions-sync/registry.toml` on macOS and `~/.local/share/mise-completions-sync/registry.toml` on Linux. Keep both `registry.toml.tmpl` files as one-line includes of the shared template.

chezmoi and mise install themselves rather than through mise, so misecompsync cannot see them and `home/dot_zshrc.tmpl` generates their two completions into the zsh cache directory.

Check where a tool actually reads its configuration before choosing a target path. tealdeer is the opposite case to misecompsync: only its cache follows the platform convention, and its config stays at `~/.config/tealdeer/config.toml` on both platforms.

## Package ownership

mise supplies portable CLI binaries on both platforms. Homebrew and apt supply bootstrap prerequisites, system integration, native libraries and anything without a usable portable release. Run `mise registry <tool>` to see which backend an alias resolves to, and change the existing declaration rather than installing a second copy through another package manager.

Cases that look wrong until you know why:

- `jq` comes from mise on every platform, and the bootstrap installs and selects it before chezmoi runs. The prerequisite hook and the `modify_` scripts for `.claude/settings.json` and `.claude.json` need it before the full tool set exists.
- `btop` comes from Homebrew on macOS and mise on Linux, because `aqua:aristocratos/btop` ships Linux builds only.
- `ffmpeg`, ImageMagick, libvips and Graphviz are native packages on both platforms.
- PostgreSQL, MySQL and Redis clients are native packages. `home/dot_zshenv.tmpl` and `home/dot_zprofile.tmpl` add the Homebrew `libpq` and `mysql-client` binary directories to `PATH`.
- Homebrew `moreutils` owns `parallel` on macOS; GNU parallel conflicts with it and Homebrew has no alternatives mechanism to separate them.
- Ubuntu's `yq` package is a different program from mise's mikefarah/yq.
- Leave Ubuntu's `htop` and `tmux` packages alone when `ubuntu-server` or a Raspberry Pi metapackage requires them.
- `github:userdocs/iperf3-static` needs an explicit `asset_pattern` and `bin` for `linux-arm64`.
- On Linux ARM64 the browser is Playwright's Chromium, because Chrome for Testing has no build for that architecture. `home/dot_local/bin/executable_update-browser.tmpl` branches on that, and `home/dot_agent-browser/config.json.tmpl` is ignored everywhere else. On Linux the browser also depends on Ansible, which installs its shared libraries and grants its executable paths AppArmor user-namespace access for sandboxing.

## Agent configuration

`~/.agents` is the source of truth: `home/dot_agents/AGENTS.md` and `home/dot_agents/skills/`. Each tool reaches it through a symlink target in the source state. Claude reads `~/.claude/CLAUDE.md` and `~/.claude/skills`, from `home/dot_claude/symlink_CLAUDE.md.tmpl` and `home/dot_claude/symlink_skills.tmpl`. Codex reads `$CODEX_HOME/AGENTS.md`, and `$CODEX_HOME` defaults to `~/.codex`, so `home/dot_codex/symlink_AGENTS.md.tmpl` covers it; `~/.codex/skills` is left alone because it holds Codex's own `.system` tree. Kimi has no symlink here and reads `~/.agents` directly.

`home/dot_local/bin/executable_z` owns creation of interactive zmx sessions, including detached agent helpers. Keep the attach and detach lifecycle there, and make `zmx-messaging` reference the executable instead of duplicating shell or PTY wrappers. Test lifecycle changes on both macOS and Ubuntu.

Application-owned JSON and TOML is patched, not replaced. `home/dot_claude/modify_private_settings.json.tmpl` and `home/modify_private_dot_claude.json.tmpl` pipe the existing file through `jq` and set only the managed keys; `.claude.json` uses `jq -sj` because Claude Code writes it without a trailing newline. `home/dot_codex/modify_private_config.toml` uses chezmoi's `setValueAtPath` on parsed TOML. Keep the secret in an environment variable rather than a `jq` argument so it stays out of the process list.

## Verify a change

Render one template without applying anything. This uses the local machine's own configuration, so it shows the current platform and profile:

```sh
chezmoi execute-template < home/dot_zshrc.tmpl
```

Apply the whole source state into a throwaway destination, which is what CI does for four platform and profile combinations:

```sh
tmp=$(mktemp -d)
mkdir -p "$tmp/home" "$tmp/cache" "$tmp/state"
cat > "$tmp/chezmoi.toml" <<EOF
[hooks.read-source-state.pre]
command = "$PWD/home/.chezmoihooks/ensure-prerequisites.sh"

[data]
installAppsFromAppStore = false
profile = "workstation"
screenshotsPath = "/tmp/Screenshots"

[data.secrets]
context7ApiKey = "placeholder"
sshPrivateKey = "placeholder"
sshPublicKey = "placeholder"
githubToken = "placeholder"
EOF
chezmoi --source "$PWD" --destination "$tmp/home" --cache "$tmp/cache" \
	--config "$tmp/chezmoi.toml" --persistent-state "$tmp/state/s.boltdb" \
	--no-tty --force apply --exclude=scripts,externals
```

Set `profile` to `server` to check that ignore rules hold, and set the secrets to empty strings to check that templates survive missing values. `--exclude=scripts,externals` matters: without it the run installs packages and downloads releases.

`.github/workflows/ci.yml` then renders every shell file and checks it with `bash -n` or `zsh -n`, `shellcheck` and `shfmt -d -i 0`. Reproduce a failure by rendering the one file with `chezmoi execute-template` and running the checker on the result.
