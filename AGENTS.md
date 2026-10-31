# dotfiles

Personal macOS and Ubuntu dotfiles managed with [chezmoi](https://chezmoi.io/). `README.md` covers installation and updates for people; this file covers what an agent needs to change the repository correctly.

## Source layout

`.chezmoiroot` points at `home`, so the source state is `home/` and the repository root holds nothing chezmoi applies. Two special files are the exception and stay at the root: `.chezmoiroot` itself, and `.chezmoiversion`, which chezmoi looks for anywhere in the source directory. Every other `.chezmoi*` file, `.chezmoi.toml.tmpl` included, resolves against the source state path and must live under `home/`.

Change the source state, never the applied target: `home/dot_zshrc.tmpl` is the file to edit, and `~/.zshrc` is its output.

Much of the source state sits in dot-prefixed directories: `home/.chezmoiscripts/`, `home/.chezmoidata/`, `home/.chezmoitemplates/`, `home/.chezmoihooks/`. `rg` and `fd` skip those unless you pass `--hidden`, so pass it when searching this repository.

Filenames carry chezmoi attributes. Each target type has its own prefix chain in a fixed order, so check [the attributes table](https://www.chezmoi.io/reference/source-state-attributes/) before renaming a source file rather than reasoning from another target type. Scripts are `run_`, then `once_` or `onchange_`, then `before_` or `after_`; `dot_` is always last on the types that allow it; `.tmpl` is the suffix. Scripts run in alphabetical order of the name with attributes stripped, which is what the numeric prefixes (`10-`, `20-`, `90-`) control.

Deleting a source file stops chezmoi from managing the target but leaves the file in the home directory. Add retired target paths to `home/.chezmoiremove` so `chezmoi apply` removes them on existing machines. Use exact paths and keep the list limited to deliberately retired configuration.

## Profiles

`.profile` is `workstation` on macOS, and `server` or `devbox` on Linux; `home/.chezmoi.toml.tmpl` prompts for the Linux value and rejects anything else. `server` is the minimal profile, so almost every conditional in the source state reads `{{ if ne .profile "server" }}`.

`home/.chezmoiignore.tmpl` drops whole target trees per platform and profile. A new target that must not reach servers or must not reach one platform belongs there, not behind a template conditional that renders an empty file.

The `server` profile carries no compiled-language toolchains, coding assistants, browser downloads, media tools, database clients, `gh` or personal SSH private keys. It keeps Python and uv, because operational scripting and `pipx:` tools need both.

## Secrets

`home/.chezmoi.toml.tmpl` fills `.secrets` from `~/.config/chezmoi/secrets.toml` when that file exists, and from Bitwarden through `rbw` otherwise. The keys are `aiRouterApiKey`, `githubToken`, `giteaToken`, `droneToken`, `dockerToken`, `cloudflareAccountId`, `cloudflareApiToken`, `flintToken`, `sshPrivateKey` and `sshPublicKey`. Every key defaults to an empty string, so a template that uses one must still render when it is empty. `home/.chezmoiignore.tmpl` is the place to skip a whole file in that case, and it keeps CLI logins off the server profile. Git uses its native credential store with one private file per host, so a successful login cannot reorder entries and leave the target out of sync. tea reads `~/Library/Application Support/tea/config.yml` on macOS and `~/.config/tea/config.yml` on Linux, so `home/.chezmoitemplates/tea-config.py` patches both.

Never commit a secret, a generated configuration file or a private key. One GitHub token serves Git, gh, mise and package downloads, so `githubToken` needs the `repo`, `read:org`, `workflow` and `read:packages` scopes. The macOS Docker script logs into GHCR, Gitea and Docker Hub with tokens it reads at run time through `"$CHEZMOI_EXECUTABLE" --config "$CHEZMOI_CONFIG_FILE" dump-config`, so neither the rendered script nor argv holds them; Linux registry logins belong to Ansible.

Ansible's `github_cli_token`, `gitea_cli_token`, `drone_cli_token` and `docker_cli_token` map to `githubToken`, `giteaToken`, `droneToken` and `dockerToken`. Bitwarden stores each token in the `fleet-cli` field of its existing service/account item; new GitHub and Gitea tokens use the label `fleet-cli`. Ansible's `cloudflare_account_id` and `cloudflare_api_token` map to `cloudflareAccountId` and `cloudflareApiToken`, which Bitwarden keeps in the `Account ID` and `API Token` fields of `cloudflare.com (yegor)`. Ansible's `flint_cli_token` maps to `flintToken`, which Bitwarden keeps in the `fleet-cli` field of `flint.usoltsev.xyz`; development profiles write it with the instance URL to `~/.config/flint/config.json`, the file `flint login` writes. wrangler has no login command for an API token, so development profiles export both as `CLOUDFLARE_ACCOUNT_ID` and `CLOUDFLARE_API_TOKEN` from `~/.config/shell/credentials.sh`, next to the Drone variables.

The server profile manages Git store files, `.npmrc` and `.netrc`; Ansible manages Docker credentials. Development profiles also manage mise's GitHub token, gh, tea, Drone, Flint, Cargo, Maven and Gradle credentials. Ignoring a client configuration preserves any old file on an existing server; remove legacy credentials only with explicit authorization.

Package clients reuse the GitHub and Gitea tokens. These hosts only download packages, so publishing credentials such as `~/.pypirc`, Gradle publishing repositories, GoReleaser tokens and Homebrew's GitHub variables stay unconfigured. `~/.npmrc` and `~/.netrc` reach every profile because servers run bun, Python and uv; Cargo, Maven and Gradle stay on development profiles. Each patcher replaces only its own entries: npm scope and `_authToken` lines for `@yegor-usoltsev` and the Gitea owners listed in `home/.chezmoidata/registries.yaml`, netrc entries for the two hosts, `gitea-<owner>` Cargo registries, and the Maven servers `github` and `gitea`, which projects must use as repository ids. `~/.gradle/gradle.properties` holds `githubUsername`, `githubToken`, `giteaUsername` and `giteaToken`, which builds read as project properties; these values override a project's own `gradle.properties`. `run_onchange_after_12-go-private.sh.tmpl` adds both hosts to `GOPRIVATE`, so Go fetches private modules directly with `~/.netrc`. GitHub has no PyPI or Cargo registry, and Helm falls back to Docker's credentials.

## Scripts

`home/.chezmoitemplates/script-header` sets `PATH` for Homebrew, `~/.local/bin` and the mise shims, includes the `log` template, and embeds the macOS build number or the distribution release so scripts rerun after an operating system upgrade. Every script under `home/.chezmoiscripts/` should include it. `home/.chezmoitemplates/log` alone gives `info`, `warn`, `success` and `error` to files that need no `PATH` changes, such as `home/dot_local/bin/executable_update.tmpl`.

A `run_once_` script runs only when its rendered content has not already completed successfully, so reverting to earlier content does not rerun it. To retrigger on a change elsewhere, embed a hash of what it depends on:

```
# config.toml hash: {{ includeTemplate "dot_config/mise/config.toml.tmpl" . | sha256sum }}
```

`home/.chezmoiscripts/run_once_after_10-mise.sh.tmpl` hashes the mise config and `run_onchange_after_11-completions.sh.tmpl` hashes the completion registry. Adding another input that must retrigger a script means adding another hash line to that script.

`home/.chezmoihooks/ensure-prerequisites.sh` runs before every source-state read and checks prerequisites. Its one download fills uv's cache for the `modify_` scripts, described below. Keep it from installing system packages or prompting: it also runs under non-interactive Ansible provisioning, where a prompt deadlocks the run. It demands an unlocked Bitwarden vault only when neither `~/.config/chezmoi/secrets.toml` nor `~/.config/chezmoi/chezmoi.toml` exists, so `chezmoi status` and `chezmoi diff` keep working on a configured machine.

Keep each file's existing shebang and portability target. Scripts under `home/.chezmoiscripts/` are bash, and `home/dot_config/shell/` is sourced by both bash and zsh. Indent with tabs. CI checks the zsh files with `zsh -n`, and the other shell files with `bash -n`, `shellcheck -s bash -e SC1090,SC1091` and `shfmt -d -i 0`.

## Modify scripts

Every `modify_` script is Python run by uv, so all of them share one language and one shape; `home/dot_cargo/modify_config.toml.tmpl` is the smallest example. chezmoi feeds the current target on stdin, empty when the target does not exist, and replaces the target with stdout. It runs them on every `status`, `diff` and `apply`, so they only read and print.

The shebang is `#!/usr/bin/env -S uv run --quiet --no-project --no-managed-python --offline --with PACKAGE --script`, without `--with` when the standard library is enough:

- `--script` is required because chezmoi runs a temporary copy named after the target, such as `/tmp/123.config.toml`.
- Dependencies go in `--with`, not in an inline `# /// script` block. uv keys inline-metadata environments by script path, so chezmoi's random path would add a cached environment on every run. Neither the packages nor Python carry a version: `--no-managed-python` makes uv run the Python that mise or the system puts on `PATH` rather than one uv installed, so keep the scripts compatible with macOS's `/usr/bin/python3`, which a fresh Mac runs until mise installs Python.
- `--no-project` keeps uv from syncing a Python project that encloses the temporary script or the working directory.
- `--offline` keeps `status` and `diff` working without a network. Without it uv revalidates its PyPI index cache after ten minutes and fails when offline. The prerequisite hook runs each distinct shebang before chezmoi reads the source state and fetches its packages without `--offline` when uv's cache lacks them, so a new dependency needs no other change. `update` sets `CHEZMOI_UV_REFRESH`, which makes the hook fetch the latest versions; until then a machine keeps the versions it fetched first.

Use the standard library for JSON, XML and netrc; `json` keeps key order. Use `tomlkit` for TOML and `ruamel.yaml` with `preserve_quotes` for YAML, because both keep the comments, order and quoting of keys the script does not own. Give a new format a round-trip parser rather than regular expressions over its text.

Each script follows the same order:

1. A comment saying what the application owns or why the file is patched rather than replaced.
2. Template data as constants rendered with `toJson`, such as `token = {{ dig "giteaToken" "" .secrets | toJson }}`. The rest is plain Python without template actions, and a script that needs no data is not a `.tmpl`.
3. Parse stdin, treating empty input as an empty document.
4. Set only the managed keys, so unmanaged keys keep their values and position. Reach nested tables through the `child(parent, key)` helper, which each script defines because the scripts share no module; it also replaces a null value, which `setdefault` would return as `None`.
5. Write the whole document to stdout.

Secrets reach a script only as those constants. The rendered script is a private temporary file, while a command-line argument would show in the process list.

A script must produce a valid file from empty input and reproduce its own output unchanged. CI's apply and `chezmoi verify` into an empty destination check both for the empty case and lint the rendered scripts with `ruff check`; for existing content, pipe a sample through the rendered script twice and compare.

## Adding a tool

Portable CLI binaries go in `home/dot_config/mise/config.toml.tmpl`. macOS packages and applications go in `home/.chezmoidata/packages.yaml`. Linux system packages belong to the `linux/cli-tools` role in the infrastructure repository, not here.

When adding a tool to the mise config:

1. Decide the profile. Wrap it in `{{ if ne .profile "server" }}` unless a server genuinely needs it.
2. Check whether misecompsync knows it. Its registry is compiled into the binary, and `home/.chezmoitemplates/mise-completions-registry` is a user overlay merged on top. A tool it does not know gets no zsh completions until you add an entry there.
3. Use the bare tool name as the registry key, not the mise backend identifier: `procs`, not `github:dalance/procs`.
4. Pick a backend. A bare registry alias resolves through mise, and `aqua:` or `github:` names a release directly when the alias is wrong or missing. `npm:` tools with native dependencies need `allow_builds = true`, which is what `min_version` guards; do not lower it. `pipx:` needs uv, which every profile has, so `pipx:httpie` sits outside the conditional; `go:` needs Go and therefore stays inside it.

The overlay renders to `~/.local/share/mise-completions-sync/registry.toml` on both platforms: misecompsync 0.5.19 reads the XDG data directory on macOS as well and ignores the old `~/Library/Application Support` copy, which `home/.chezmoiremove` deletes.

mise's `postinstall` hook runs misecompsync with `--new-only`, which reads `MISE_INSTALLED_TOOLS` and regenerates completions for the tools that command installed or upgraded. A full pass takes four seconds and a single tool takes a tenth of one, so the hook stays cheap enough to fire on every `mise use`.

The hook line sets its own `PATH` first. mise runs it through `sh -o errexit -c` and puts only the freshly installed tools on `PATH`, so misecompsync needs the shims directory and `mise` itself needs `~/.local/bin`; without both, the hook works from a login shell and fails under Ansible and cron. A failing hook is a warning rather than an error, so the miss would be silent.

`run_onchange_after_11-completions.sh.tmpl` exists for the one case the hook cannot see: editing the overlay changes how an already installed tool generates its completions, and no installation happens. It does the full pass.

chezmoi and mise install themselves rather than through mise, so misecompsync cannot see them and `home/dot_zshrc.tmpl` generates their two completions into the zsh cache directory.

Check where a tool actually reads its configuration before choosing a target path. tealdeer is the opposite case to misecompsync: only its cache follows the platform convention, and its config stays at `~/.config/tealdeer/config.toml` on both platforms.

## Package ownership

mise supplies portable CLI binaries on both platforms. Homebrew and apt supply bootstrap prerequisites, system integration, native libraries and anything without a usable portable release. Run `mise registry <tool>` to see which backend an alias resolves to, and change the existing declaration rather than installing a second copy through another package manager.

Cases that look wrong until you know why:

- `uv` comes from mise on every platform, and the bootstrap and the infrastructure repository's `linux/mise` role install and select it before chezmoi runs. chezmoi runs the `modify_` scripts through it on its first `status`, before the dotfiles mise configuration has installed anything, and the prerequisite hook checks for it.
- Git comes from Homebrew on macOS and from the git-core PPA, installed by the infrastructure repository, on Ubuntu. The `[hook "prek"]` section in `home/dot_gitconfig.tmpl` runs every repository's prek or pre-commit config at `pre-commit` without `prek install`, and Git before 2.54 silently ignores it. A repository opts out with `git config hook.prek.enabled false`.
- `btop` comes from Homebrew on macOS and mise on Linux, because `aqua:aristocratos/btop` ships Linux builds only.
- `ffmpeg`, ImageMagick, libvips and Graphviz are native packages on both platforms.
- PostgreSQL, MySQL and Redis clients are native packages. `home/dot_zshenv.tmpl` and `home/dot_zprofile.tmpl` add the Homebrew `libpq` and `mysql-client` binary directories to `PATH`.
- Homebrew `moreutils` owns `parallel` on macOS; GNU parallel conflicts with it and Homebrew has no alternatives mechanism to separate them.
- Ubuntu's `yq` package is a different program from mise's mikefarah/yq.
- Leave Ubuntu's `htop` and `tmux` packages alone when `ubuntu-server` or a Raspberry Pi metapackage requires them.
- `github:userdocs/iperf3-static` needs an explicit `asset_pattern` and `bin` for `linux-arm64`.
- On Linux ARM64 the browser is Playwright's Chromium, because Chrome for Testing has no build for that architecture. `home/dot_local/bin/executable_update-browser.tmpl` branches on that, and `home/dot_agent-browser/config.json.tmpl` is ignored everywhere else. On Linux the browser also depends on Ansible, which installs its shared libraries and grants its executable paths AppArmor user-namespace access for sandboxing.

## Agent configuration

`~/.agents` is the source of truth: `home/dot_agents/AGENTS.md` and `home/dot_agents/skills/`. Claude reads `~/.claude/CLAUDE.md` and `~/.claude/skills` through `home/dot_claude/symlink_CLAUDE.md.tmpl` and `home/dot_claude/symlink_skills.tmpl`. Codex reads `$CODEX_HOME/AGENTS.md` through `home/dot_codex/symlink_AGENTS.md.tmpl` and `~/.agents/skills` natively; `~/.codex/skills` is left alone because it holds Codex's own `.system` tree.

The global rules stay short and lean on each provider's own system prompt and on T3 Code; procedures live in skills, which the rules mention by name only. Every skill is model-invocable, and its `description` names English trigger words and says "in any language", because the user often writes in Russian. The repository holds no Cyrillic except `humanizer-ru`, which edits Russian text.

The local skills are `agent-browser`, `artifact`, `autopilot`, `flint`, `open-pr`, `readme`, `retro` and `review-loop`. `review-loop` merges tstack's `council` and `sol-loop`, `open-pr` adapts its `file-pr` to GitHub and Gitea, and `autopilot` merges `full-send` and `full-stop` with PR mode as the default; all three come from [t3dotgg/tstack](https://github.com/t3dotgg/tstack) (MIT) and are maintained here rather than re-imported. `doc-coauthoring` ([anthropics/skills](https://github.com/anthropics/skills), Apache 2.0), `humanizer` ([blader/humanizer](https://github.com/blader/humanizer), MIT) and `humanizer-ru` ([ilyautov/humanizer-ru](https://github.com/ilyautov/humanizer-ru), MIT) are vendored copies with their licenses; refresh them by copying the upstream skill directory again. `flint` is the stub from [flint](https://github.com/yegor-usoltsev/flint) with the instance URLs and the backlog policy added; the guide comes from `flint skill`.

Application-owned JSON and TOML is patched, not replaced. `home/dot_claude/modify_private_settings.json.tmpl` and `home/dot_codex/modify_private_config.toml.tmpl` set only attribution, the permission and sandbox modes, and the ai-router endpoint; everything else stays at the provider's default. Both CLIs reach the Claude and Codex subscriptions through ai-router (CLIProxyAPI) with `aiRouterApiKey`, which Bitwarden keeps in the `API Key 1` field of `ai-router.usoltsev.xyz (gateway, proxy, cli, api)` and Ansible passes as `ai_router_api_key`. Without the key both fall back to their own login. The infrastructure repository routes only Claude Code's own requests to the Claude accounts.

T3 Code is the shared interface on every development machine. `home/dot_t3/userdata/` patches its server settings on both platforms and, on macOS, the desktop app's client settings and network exposure. `linkedEnvironmentsEnabled` lets agents on one machine delegate to another; the link itself is a one-time `t3 environment link` with a pairing code. macOS installs the `t3-code` cask and links `~/.local/bin/t3` to the launcher the app writes; on Linux the infrastructure repository installs the CLI and its user service, and `update` runs `t3 update --yes`.

`home/private_dot_ssh/modify_private_config.tmpl` owns only the block between `# BEGIN dotfiles` and `# END dotfiles` at the top of `~/.ssh/config`, so hosts added by hand, VS Code Remote-SSH or OrbStack survive.

`update-mobile-sdk` installs the latest stable Android platform, build-tools, platform-tools and emulator into the mise `android-sdk` directory and, on macOS, the simulator runtime for the Xcode that Xcodes.app selected. Projects install their own system images and virtual devices. Linux needs the `kvm` group, which Ansible grants.

`~/dev/clone-all.sh` clones the allowed owners' repositories from GitHub and Gitea and registers them as T3 projects; `~/dev/pull-all.sh` fast-forwards checkouts on their default branch.

## Verify a change

Keep tests and test fixtures out of this repository. Verify changes with isolated chezmoi renders and applies, existing linters, and temporary files for one-off behavioral checks.

Render one template without applying anything. This uses the local machine's own configuration, so it shows the current platform and profile:

```sh
chezmoi execute-template < home/dot_zshrc.tmpl
```

Apply the whole source state into a throwaway destination, which is what CI does for three platform and profile combinations, each with filled and empty secrets:

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
aiRouterApiKey = "placeholder"
sshPrivateKey = "placeholder"
sshPublicKey = "placeholder"
githubToken = "placeholder"
giteaToken = "placeholder"
droneToken = "placeholder"
dockerToken = "placeholder"
cloudflareAccountId = "placeholder"
cloudflareApiToken = "placeholder"
EOF
chezmoi --source "$PWD" --destination "$tmp/home" --cache "$tmp/cache" \
	--config "$tmp/chezmoi.toml" --persistent-state "$tmp/state/s.boltdb" \
	--no-tty --force apply --exclude=scripts,externals
```

Set `profile` to `server` to check that ignore rules hold, and set the secrets to empty strings to check that templates survive missing values. `--exclude=scripts,externals` matters: without it the run installs packages and downloads releases.

`.github/workflows/ci.yml` then renders every shell file and checks it with `bash -n` or `zsh -n`, `shellcheck` and `shfmt -d -i 0`. Reproduce a failure by rendering the one file with `chezmoi execute-template` and running the checker on the result.
