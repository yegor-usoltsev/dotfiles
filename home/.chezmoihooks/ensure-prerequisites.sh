#!/usr/bin/env bash
set -euo pipefail

error() { printf '\033[0;31m==> ERROR: %s\033[0m\n' "$1" >&2 && exit 1; }

# This hook checks prerequisites and fills uv's cache; it never installs system
# packages or prompts, which could deadlock a non-interactive chezmoi run such as
# Ansible provisioning.
case "$(uname -s)" in
Darwin)
	rbw_fix="brew install rbw"
	;;
*)
	rbw_fix="sudo apt-get install --yes rbw"
	;;
esac

command -v uv >/dev/null 2>&1 ||
	error "uv is missing from PATH; run: mise use --global uv@latest and add ~/.local/share/mise/shims to PATH"

# The modify_ scripts run uv with --offline, so status and diff work without a
# network even after uv's index cache goes stale. When the cache lacks the
# Python or the packages one of their shebangs pins, fetch them once here; this
# downloads into uv's cache and never prompts.
source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
find "$source_dir" -type f \( -name 'modify_*' -o -path '*/.chezmoitemplates/*.py' \) -exec awk 'FNR == 1' {} + |
	sed -n 's|^#!/usr/bin/env -S \(uv run .*\) --script$|\1|p' | sort -u |
	while IFS= read -r command; do
		/usr/bin/env -S "$command" python -c '' 2>/dev/null ||
			/usr/bin/env -S "${command/ --offline/}" python -c '' ||
			error "uv could not fetch what the modify_ scripts need: $command"
	done

# Bitwarden is only read while the config template is being evaluated, which
# happens when no generated config exists yet. Demanding an unlocked vault on
# every command would break `chezmoi status` and `chezmoi diff` on a machine
# whose config was generated long ago.
if [ ! -f "$HOME/.config/chezmoi/secrets.toml" ] && [ ! -f "$HOME/.config/chezmoi/chezmoi.toml" ]; then
	command -v rbw >/dev/null 2>&1 || error "rbw is missing; run: $rbw_fix"
	rbw unlocked >/dev/null 2>&1 || error "Bitwarden is locked; run: rbw unlock"
fi
