#!/usr/bin/env bash
set -euo pipefail

# Interactive prerequisites; Ansible provisions Linux hosts separately.

prompt() { read -rp $'\033[0;35m==> \033[0m'"$1" "$2"; }
info() { printf '\033[0;34m==> %s\033[0m\n' "$1"; }
success() { printf '\033[0;32m==> %s\033[0m\n' "$1"; }
error() { printf '\033[0;31m==> ERROR: %s\033[0m\n' "$1" >&2 && exit 1; }

ensure_homebrew() {
	if command -v brew >/dev/null; then
		info "Homebrew already installed"
		return
	fi
	info "Installing Homebrew..."
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/opt/homebrew/bin/brew shellenv)"
	success "Homebrew installed"
}

ensure_brew_packages() {
	local packages=(rbw) missing=()
	for package in "${packages[@]}"; do
		command -v "$package" >/dev/null 2>&1 || missing+=("$package")
	done
	if [ ${#missing[@]} -eq 0 ]; then
		info "System packages already installed"
		return
	fi
	info "Installing ${missing[*]}..."
	brew install "${missing[@]}"
	success "System packages installed"
}

ensure_apt_packages() {
	local packages=(ca-certificates curl git pinentry-curses rbw unzip xz-utils zsh) missing=()
	for package in "${packages[@]}"; do
		dpkg-query -s "$package" >/dev/null 2>&1 || missing+=("$package")
	done
	if [ ${#missing[@]} -eq 0 ]; then
		info "System packages already installed"
		return
	fi
	sudo apt-get update
	for package in "${missing[@]}"; do
		apt-cache show "$package" >/dev/null 2>&1 ||
			error "$package is not packaged for this release; install it by hand and rerun"
	done
	info "Installing ${missing[*]}..."
	sudo apt-get install --yes "${missing[@]}"
	success "System packages installed"
}

ensure_mise() {
	if command -v mise >/dev/null; then
		info "mise already installed"
		return
	fi
	info "Installing mise..."
	curl -fsSL https://mise.run | sh
	export PATH="$HOME/.local/bin:$PATH"
	success "mise installed"
}

# chezmoi needs jq before the dotfiles mise configuration exists.
ensure_mise_jq() {
	local mise_bin="$HOME/.local/bin/mise"
	local shim="$HOME/.local/share/mise/shims/jq"
	if command -v mise >/dev/null 2>&1; then
		mise_bin="$(command -v mise)"
	fi
	if "$shim" --version >/dev/null 2>&1; then
		info "jq already installed with mise"
		return
	fi
	info "Installing jq with mise..."
	if ! "$mise_bin" install jq >/dev/null 2>&1 || ! "$shim" --version >/dev/null 2>&1; then
		"$mise_bin" use --global --yes jq@latest
	fi
	"$shim" --version >/dev/null 2>&1 || error "mise could not provide jq"
	success "jq installed"
}

ensure_bitwarden() {
	if rbw unlocked >/dev/null 2>&1 || rbw unlock >/dev/null 2>&1; then
		success "Bitwarden unlocked"
		return
	fi
	local bw_email bw_server_url
	prompt "Bitwarden email address: " bw_email
	if [ -z "$bw_email" ]; then
		error "Email address is required"
	fi
	rbw config set email "$bw_email"
	prompt "Bitwarden server URL (leave blank for default): " bw_server_url
	if [ -n "$bw_server_url" ]; then
		rbw config set base_url "$bw_server_url"
	fi
	info "Logging in to Bitwarden..."
	rbw login
	rbw unlock
	success "Bitwarden authenticated and unlocked"
}

case "$(uname -s)" in
Darwin)
	ensure_homebrew
	ensure_brew_packages
	ensure_mise
	ensure_mise_jq
	;;
Linux)
	distribution="Linux"
	if [ -r /etc/os-release ]; then
		# shellcheck disable=SC1091
		. /etc/os-release
		distribution="${PRETTY_NAME:-${NAME:-${ID:-Linux}}}"
	fi
	command -v apt-get >/dev/null 2>&1 ||
		error "Unsupported Linux distribution: $distribution; apt-get is required"
	ensure_apt_packages
	ensure_mise
	ensure_mise_jq
	;;
*)
	error "Unsupported operating system: $(uname -s)"
	;;
esac
ensure_bitwarden
