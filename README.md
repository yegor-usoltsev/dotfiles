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

## Working on this repository

[AGENTS.md](AGENTS.md) documents the source layout, the profile and secret conventions, package ownership between mise and the native package managers, and how to render and verify a change without applying it. `CLAUDE.md` is a symlink to it.

Keep local secrets, generated configuration and private keys out of Git.
