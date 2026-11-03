# dotfiles

Personal macOS and Ubuntu dotfiles managed with chezmoi.

## Source layout

Edit source state under `home/`, never applied targets. `.chezmoiroot` and `.chezmoiversion` stay at the repository root; all other `.chezmoi*` files resolve against `home/`. Pass `--hidden` to `rg` and `fd` to include the source state's dot-prefixed directories.

Check chezmoi's [attribute ordering table](https://www.chezmoi.io/reference/source-state-attributes/) before renaming: prefix chains differ by target type. Scripts use `run_`, then `once_`/`onchange_`, then `before_`/`after_`; `dot_` is last where allowed, and `.tmpl` is a suffix. Script execution sorts names with attributes stripped, so numeric prefixes control order.

Deleting source leaves the target behind. Remove retired targets manually on each machine; do not maintain a removal list.

## Profiles

macOS uses `workstation`; Linux accepts only `server` or `devbox`. New targets excluded by platform or profile belong in `home/.chezmoiignore.tmpl`, rather than rendering empty files. Default development tools to `{{ if ne .profile "server" }}`; servers retain Python and uv but exclude compiled-language toolchains, assistants, browsers, media/database tools, gh and personal SSH keys.

## Secrets

`home/.chezmoi.toml.tmpl` reads `~/.config/chezmoi/secrets.toml`, otherwise Bitwarden via rbw. Secrets default to empty strings: templates must still render; skip whole targets in `.chezmoiignore.tmpl` when needed. Ignoring leaves existing credentials intact; deleting legacy credentials needs explicit authorization.

Never commit secrets, private keys or generated configuration. Never put secrets in argv. Shell scripts read them at runtime with `"$CHEZMOI_EXECUTABLE" --config "$CHEZMOI_CONFIG_FILE" dump-config`; modify scripts use rendered constants below. Docker registry logins on Linux belong to Ansible.

GitHub's shared token needs `repo`, `read:org`, `workflow` and `read:packages`. Ansible maps `{github,gitea,drone,docker,flint}_cli_token` to the corresponding `<service>Token`, `ai_router_api_key` to `aiRouterApiKey`, and `cloudflare_account_id`/`cloudflare_api_token` to `cloudflareAccountId`/`cloudflareApiToken`. Bitwarden service tokens use `fleet-cli`; ai-router uses `API Key 1`, and Cloudflare uses `Account ID`/`API Token`. New GitHub/Gitea tokens use the label `fleet-cli`.

Package credentials are for downloads; leave publishing credentials unconfigured. Maven projects must use repository ids `github` and `gitea`; managed Gradle user properties override project properties. Servers manage Git store files, `.npmrc` and `.netrc`; other CLI logins stay on development profiles.

## Scripts

Include `home/.chezmoitemplates/script-header` in every `.chezmoiscripts/` script: it supplies PATH, logging and OS-version content that retriggers setup after upgrades. Use `log` alone when PATH changes are unnecessary. Preserve portability: setup scripts are bash; `home/dot_config/shell/` is shared by bash and zsh.

`run_once_` remembers successful rendered content, including earlier versions: reverting does not rerun it. Hash dependencies that must retrigger a script, for example:

```gotemplate
# config.toml hash: {{ includeTemplate "dot_config/mise/config.toml.tmpl" . | sha256sum }}
```

`home/.chezmoihooks/ensure-prerequisites.sh` runs before source-state reads. It must never install system packages or prompt, including under Ansible. Downloads only populate uv's cache. Require unlocked Bitwarden only when neither the secrets file nor generated chezmoi config exists.

## Modify scripts

All `modify_` scripts are Python through uv. chezmoi supplies the existing target on stdin and replaces it with stdout; `status`, `diff` and `apply` all run them, so permit no side effects. Empty input must produce a valid document; rerunning on the output must leave it unchanged. Patch only managed entries and preserve unrelated content.

```text
#!/usr/bin/env -S uv run --quiet --no-project --no-managed-python --offline --with PACKAGE --script
```

- `--quiet` keeps uv chatter out of normal runs; omit `--with` for standard-library scripts.
- `--script` handles chezmoi's temporary filenames, which need not end in `.py`.
- Use `--with`, never inline script metadata: uv keys metadata environments by path, so random temporary paths would accumulate environments.
- `--no-managed-python` uses PATH's Python; keep compatibility with macOS's `/usr/bin/python3`. Pin neither Python nor dependency versions.
- `--no-project` prevents syncing an enclosing Python project.
- `--offline` keeps status/diff independent of index freshness and networking. The prerequisite hook discovers shebangs and fetches missing dependencies; `update` sets `CHEZMOI_UV_REFRESH` to refresh them.

Use the standard library for JSON/XML/netrc, `tomlkit` for TOML and `ruamel.yaml` with `preserve_quotes` for YAML. New structured formats need round-trip parsers, not regexes. Render template data, including secrets, as constants with `toJson`; keep the remaining Python free of template actions. Use no `.tmpl` suffix when no data is needed. See `home/dot_cargo/modify_config.toml.tmpl` for the pattern.

## Adding a tool

Portable CLIs belong in `home/dot_config/mise/config.toml.tmpl`; macOS packages/apps in `home/.chezmoidata/packages.yaml`; Linux system packages in the infrastructure repository's `linux/cli-tools` role.

1. Choose the profile; exclude servers unless they need the tool.
2. Check misecompsync's built-in registry; add unknown tools to `home/.chezmoitemplates/mise-completions-registry` using bare names (`procs`, not `github:dalance/procs`). The overlay lives at `~/.local/share/mise-completions-sync/registry.toml` on both platforms.
3. Check `mise registry <tool>` before choosing an alias or explicit backend; change existing declarations rather than installing duplicate copies. Native npm dependencies require `allow_builds = true`; do not lower `min_version`. `pipx:` needs uv, available everywhere; `go:` requires the development-only Go toolchain.

Keep the postinstall hook's explicit PATH for shims and `~/.local/bin`: mise supplies only newly installed tools on PATH. `--new-only` handles installations; the hashed `run_onchange_after_11-completions.sh.tmpl` handles overlay edits. chezmoi/mise install themselves, so zsh generates their completions separately.

Check cross-platform config locations: tealdeer uses `~/.config/tealdeer/config.toml` on both platforms despite its platform-specific cache.

## Package ownership

Homebrew/apt own bootstrap prerequisites, native libraries and system integration. Preserve these exceptions:

- Bootstrap/Ansible must install and select mise's uv before the first chezmoi source-state read.
- Git comes from Homebrew or Ubuntu's git-core PPA. Config-based prek hooks require Git 2.54+ and need no `prek install`; opt out per repository with `git config hook.prek.enabled false`.
- btop is Homebrew on macOS, mise on Linux: its aqua backend has only Linux builds.
- ffmpeg, ImageMagick, libvips, Graphviz and PostgreSQL/Redis clients are native packages on both platforms; macOS also has mysql-client. Homebrew's libpq/mysql-client need their own PATH entries.
- Homebrew moreutils owns `parallel` and conflicts with GNU parallel; no alternatives mechanism separates them.
- Ubuntu yq is a different program from mikefarah/yq. Keep distro htop/tmux when Ubuntu Server or Raspberry Pi metapackages require them.
- `github:userdocs/iperf3-static` needs explicit `asset_pattern` and `bin` on `linux-arm64`.
- Linux ARM64 uses Playwright Chromium; Chrome for Testing lacks that build. Only that platform receives `.agent-browser/config.json`. Ansible supplies Linux browser libraries and AppArmor user-namespace permissions.

## Agent configuration

`~/.agents` is authoritative for global rules and skills; Claude/Codex use symlinks. Leave `~/.codex/skills` alone: it contains Codex's `.system` tree. Application-owned configuration is patched, not replaced. Third-party skills come from upstream through `home/.chezmoiexternal.toml`; never copy them into source state. Every local skill is model-invocable, and its `description` names English trigger words and says "in any language"; the repository holds no Cyrillic. The global media rule was tested on GitHub, Gitea 28 and Flint: GitHub rejects AVIF uploads and drops `<video>` unless it points at its own uploads, Gitea strips `<audio>` and rejects `.weba`, `.ogg` and `.opus`, and Safari plays AV1 only with a hardware decoder. Claude keeps telemetry on because `DISABLE_TELEMETRY` and `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` also stop feature-flag fetching.

## Verify a change

Keep tests/fixtures out of this repository. Use isolated renders/applies, existing linters and temporary behavioral samples. Render a template using the current machine's profile:

```sh
chezmoi execute-template < home/dot_zshrc.tmpl
```

From the repository root, apply into a throwaway destination without running installation scripts or downloading externals:

```sh
tmp=$(mktemp -d)
mkdir -p "$tmp/home" "$tmp/cache" "$tmp/state"
cat > "$tmp/chezmoi.toml" <<EOF_CONFIG
[hooks.read-source-state.pre]
command = "$PWD/home/.chezmoihooks/ensure-prerequisites.sh"
[data]
installAppsFromAppStore = false
profile = "workstation"
screenshotsPath = "/tmp/Screenshots"
[data.secrets]
EOF_CONFIG
for key in aiRouterApiKey sshPrivateKey sshPublicKey githubToken giteaToken droneToken dockerToken cloudflareAccountId cloudflareApiToken flintToken; do
	printf '%s = "placeholder"\n' "$key" >> "$tmp/chezmoi.toml"
done
chezmoi --source "$PWD" --destination "$tmp/home" --cache "$tmp/cache" \
	--config "$tmp/chezmoi.toml" --persistent-state "$tmp/state/s.boltdb" \
	--no-tty --force apply --exclude=scripts,externals
```

Repeat with empty secrets and the host's applicable profiles (`server`/`devbox` on Linux). Run `verify` with the same options/exclusions to check idempotence. For existing content, pipe a sample through a rendered modify script twice and compare.

`.github/workflows/ci.yml` covers macOS workstation, Linux devbox/server and empty/filled secrets. It lints rendered Python with `ruff check --isolated`; zsh with `zsh -n`; other shell with `bash -n`, `shellcheck -s bash -e SC1090,SC1091` and `shfmt -d -i 0` after whitespace normalization.

## Pull requests

- CodeRabbit and cubic skip drafts and Renovate. After each push, wait for CI/reviews and read inline comments with `gh api --paginate repos/{owner}/{repo}/pulls/<n>/comments`.
- Verify findings against code. Fix real defects in one commit per round; decline nits, redundant or speculative findings with one line of evidence and resolve the thread. Do not argue twice.
- Stop after two fix rounds; nits do not block merging. Use `gh pr merge --squash` once CI is green and no comment identifies a real defect.
