# dotfiles

Personal dotfiles that keep terminal tools and development environments consistent across macOS and Ubuntu, managed with [chezmoi](https://chezmoi.io/).

- **macOS:** `workstation` includes development tools and desktop applications.
- **Ubuntu development:** `devbox` includes development CLI tools.
- **Ubuntu servers:** `server` keeps shell and operational tools, Python and uv; skips development toolchains, coding assistants and personal SSH private keys.

mise supplies shared CLI tools and runtimes. Homebrew supplies macOS applications and native packages; the infrastructure repository's Ansible roles supply Ubuntu system packages.

## Interactive install

Run the bootstrap first to install prerequisites and unlock Bitwarden, then initialize chezmoi:

```sh
bash -c "$(curl -fsLS https://raw.githubusercontent.com/yegor-usoltsev/dotfiles/main/.bootstrap.sh)"
PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH" sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply --source "$HOME/dev/yegor-usoltsev/dotfiles" yegor-usoltsev
```

Ubuntu prompts for `server` (default) or `devbox`. For a complete Ubuntu setup, use the infrastructure playbook to install native packages, Docker and system configuration.

## Ansible-provisioned Ubuntu

Ansible supplies chezmoi, mise and `~/.config/chezmoi/secrets.toml`, allowing installation without Bitwarden prompts:

```sh
export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
chezmoi init --source "$HOME/dev/yegor-usoltsev/dotfiles" --promptString profile=devbox yegor-usoltsev
chezmoi apply
```

## Updates

Run `update` to upgrade native packages, chezmoi, mise and its tools, pull and apply the dotfiles, and on workstations and devboxes update the browser and the Paseo plugins. Use `chezmoi update` to update only the dotfiles.

## Working on this repository

[AGENTS.md](AGENTS.md) covers source layout, conventions and verification. Edit the repository's source files; keep secrets, generated configuration and private keys out of Git.
