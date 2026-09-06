#!/usr/bin/env bash
set -euo pipefail

error() { printf '\033[0;31m==> ERROR: %s\033[0m\n' "$1" >&2 && exit 1; }

# This hook deliberately only checks prerequisites. Installing or prompting here
# could deadlock a non-interactive chezmoi run such as Ansible provisioning.
case "$(uname -s)" in
Darwin)
	rbw_fix="brew install rbw"
	;;
*)
	rbw_fix="sudo apt-get install --yes rbw"
	;;
esac

command -v jq >/dev/null 2>&1 ||
	error "jq is missing from PATH; run: mise use --global jq@latest and add ~/.local/share/mise/shims to PATH"

# Bitwarden is only read while the config template is being evaluated, which
# happens when no generated config exists yet. Demanding an unlocked vault on
# every command would break `chezmoi status` and `chezmoi diff` on a machine
# whose config was generated long ago.
if [ ! -f "$HOME/.config/chezmoi/secrets.toml" ] && [ ! -f "$HOME/.config/chezmoi/chezmoi.toml" ]; then
	command -v rbw >/dev/null 2>&1 || error "rbw is missing; run: $rbw_fix"
	rbw unlocked >/dev/null 2>&1 || error "Bitwarden is locked; run: rbw unlock"
fi
