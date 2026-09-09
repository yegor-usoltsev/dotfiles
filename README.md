# dotfiles

Personal macOS and Ubuntu dotfiles managed with [chezmoi](https://chezmoi.io/). Shared CLI tools and runtimes come from mise; macOS applications and native packages come from Homebrew. Ubuntu system packages come from the `linux/cli-tools` Ansible role in the infrastructure repository.

A profile decides how much a machine gets:

| Profile | Machines | Tools |
| --- | --- | --- |
| `workstation` | macOS | Full development environment and desktop applications |
| `devbox` | Ubuntu development hosts | The same development CLI tools, without macOS applications |
| `server` | Small Ubuntu hosts | Shell, editor, Git, monitoring, file transfer, networking and container tools, plus Python and uv |

Servers skip compiled-language toolchains, coding assistants, browser downloads, media tools, database clients, `gh` and personal SSH private keys. They keep Python and uv, because operational scripting and `pipx:` tools need both.

Every machine gets zsh, mise, starship, fzf and zoxide. Bash stays available as a fallback on Linux. Tool versions track `latest`, except Node LTS, Java Zulu 25 and stable Rust.

## Interactive install

Run the bootstrap before initializing chezmoi: configuration reads secrets from Bitwarden before installation scripts can run.

```sh
bash -c "$(curl -fsLS https://raw.githubusercontent.com/yegor-usoltsev/dotfiles/main/.bootstrap.sh)"
PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH" sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply --source "$HOME/dev/yegor-usoltsev/dotfiles" yegor-usoltsev
```

The explicit binary and source directories match the generated configuration and let chezmoi update itself. macOS uses `workstation`; Ubuntu prompts for `server` or `devbox` and defaults to `server`.

The second command runs in a new shell that inherits nothing the bootstrap exported, so it names the mise shims and `~/.local/bin` itself. Bootstrap installs `jq` with mise and selects it globally, and the prerequisite hook and the `modify_` scripts find it through those shims.

On Ubuntu, bootstrap installs prerequisites and chezmoi installs user tools. Ansible supplies the full native package set, Docker, system configuration and the zsh login shell. Use the infrastructure playbook for a complete dev box.

## Ansible-provisioned Ubuntu

Ansible installs chezmoi and mise into `~/.local/bin`, writes a mode `0600` `~/.config/chezmoi/secrets.toml`, and initializes the selected profile:

```sh
export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
chezmoi init --source "$HOME/dev/yegor-usoltsev/dotfiles" --promptString profile=devbox yegor-usoltsev
chezmoi apply
```

Ansible sets the same `PATH` on its chezmoi tasks and selects the mise `jq` in the `linux/mise` role, so provisioning never needs a login shell.

The secrets file may hold `context7ApiKey`, `githubToken`, `sshPrivateKey` and `sshPublicKey`. Missing keys default to empty, and the file's presence disables interactive Bitwarden access. Ansible gives personal SSH keys to dev boxes only; servers receive authorized keys separately.

`chezmoi init` clones only when the source directory holds no Git repository. Use `chezmoi update` to fetch and apply later changes.

## Updates

Run `update` on any machine. It upgrades native packages, chezmoi and mise, pulls and applies the dotfiles, then upgrades mise tools. On Ubuntu it reports when a reboot is needed. A normal Ansible run performs the equivalent updates on provisioned hosts.

`.chezmoiversion` and mise's `min_version` declare the minimum supported versions; installers and self-updaters fetch the latest releases.

`mise ls` shows installed versions and `mise registry <tool>` shows which backend an alias resolves to.

## Sign-in and first-run setup

chezmoi and Ansible install and configure tools, but they cannot authenticate them. The tools below need credentials, a license or a manual first launch before they reach an external service. Sessions expire, so several of these repeat rather than happening once per machine.

The generated chezmoi configuration does supply two credentials from `~/.config/chezmoi/secrets.toml` or Bitwarden: the Context7 API key and the GitHub token that mise uses for release downloads. The token only lifts the unauthenticated API rate limit and does not authenticate `gh`.

### Command-line tools

| Tool | Profiles | Setup |
| --- | --- | --- |
| `rbw` | all | `rbw login`, then `rbw unlock` before every chezmoi run that reads secrets from Bitwarden. Skipped when `~/.config/chezmoi/secrets.toml` exists. |
| `rclone` | all | `rclone config` per remote; local paths work without it |
| `dufs` | all | serves anonymously unless you pass `--auth`; credentials are yours to choose |
| `caddy` | all | needs an ACME-reachable domain or an internal CA before it serves TLS |
| `tssh`, `tsshd` | all | reuses `~/.ssh/config`; UDP mode needs `tsshd` installed on the far side |
| `git` | all | `git config user.name` and `user.email` if the dotfiles do not already set yours |
| `gh` | workstation, devbox | `gh auth login`; public read-only commands work without it |
| `git-lfs` | workstation, devbox | `git lfs install` once per user account to register the Git filters |
| `tea` | workstation, devbox | `tea login add` per Gitea host |
| `awscli` | workstation, devbox | `aws configure` for access keys, or `aws configure sso` and then `aws sso login --profile <name>` |
| `kubectl`, `helm` | workstation, devbox | a kubeconfig; nothing here generates one |
| `terraform` | workstation, devbox | provider credentials per project; `terraform login` only for HCP Terraform |
| `drone` | workstation, devbox | `DRONE_SERVER` and `DRONE_TOKEN` in the environment; `drone exec` and `drone lint` run locally without them |
| `claude` | workstation, devbox | `claude` prompts to sign in on first run, or reads `ANTHROPIC_API_KEY` |
| `codex` | workstation, devbox | `codex login` |
| `grok` | workstation, devbox | sign-in or an xAI API key |
| `kimi` | workstation, devbox | sign-in or a Moonshot API key |
| `pi` | workstation, devbox | credentials for one supported provider |
| `agent-browser` | workstation, devbox | works out of the box; point it at a logged-in browser profile only to automate authenticated sites |
| `yt-dlp` | workstation, devbox | cookies or `--username` for members-only sources |
| `psql`, `mysql`, `redis-cli` | workstation | per-host credentials, usually `~/.pgpass` or `~/.my.cnf` |
| `docker`, `lazydocker` | workstation, devbox | needs a running daemon: OrbStack on macOS, the Ansible-installed Docker on Ubuntu |

### macOS applications

Accounts, all signed out on a fresh machine:

| Application | Setup |
| --- | --- |
| App Store | sign in with your Apple ID before `mas` can install anything |
| Bitwarden, Dashlane | account sign-in and vault unlock |
| Slack, Telegram, Zoom | account sign-in; Zoom can join meetings without one |
| Spotify, ChatGPT | account sign-in |
| Windows App | Microsoft account or a workspace URL per remote host |
| Happ | subscription or configuration URL |
| Tailscale | sign in through the app, or `tailscale up` from the CLI |
| Xcodes | Apple ID to download toolchains |
| Ledger Live | pair and unlock the hardware wallet |

Licenses and paid tiers:

| Application | Setup |
| --- | --- |
| IntelliJ IDEA | JetBrains account or a license key |
| Proxyman | free tier works; paid features need a license |
| HTTP Toolkit | free tier works; account sign-in unlocks the paid features |
| BetterDisplay | free tier works; a license unlocks the rest |

First-launch configuration and system permissions:

| Application | Setup |
| --- | --- |
| Proxyman, HTTP Toolkit | install and trust the root certificate, then pick the clients to intercept |
| OpenLens | add a cluster or point it at a kubeconfig |
| OrbStack | first launch installs its system integration and CLI helpers |
| Raycast | accessibility and automation permissions for the extensions that need them |
| Handy | microphone access, accessibility for paste, and a speech model download |
| Amphetamine | notification and, for some triggers, location or accessibility access |
| Pearcleaner | Full Disk Access for its deeper cleanup modes |
| CodexBar | credentials or local session access for the sources it reports on |
| UTM | create or import a virtual machine; ARM guests need matching images |
| Ghostty | grant access when a shell command first asks for Documents, Downloads or automation |
| Keka, IINA, Transmission | set them as the default handler for the file types you want |
| Safari extensions | SponsorBlock and wBlock install disabled; enable them in Safari settings |
| Firefox, Helium | sign in for sync, import bookmarks, choose a default browser |
| Obsidian | open or create a vault; an account is needed only for Sync and Publish |
| Things | Things Cloud account for sync; local use works without one |
| Visual Studio Code, Zed | settings and extensions come from this repository; sign in only for account-backed sync and AI features |
| BetterDisplay, blueutil, duti | configure the displays, Bluetooth devices and file associations you want them to manage |

Entries in the last two tables reflect what each application usually asks for. Verify the details for Happ, Handy, Pearcleaner and CodexBar against their own documentation.

## Working on this repository

[AGENTS.md](AGENTS.md) documents the source layout, the profile and secret conventions, package ownership between mise and the native package managers, and how to render and verify a change without applying it. `CLAUDE.md` is a symlink to it.

Keep local secrets, generated configuration and private keys out of Git.
