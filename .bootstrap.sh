#!/usr/bin/env bash
set -euo pipefail

prompt() { read -rp $'\033[0;35m==> \033[0m'"$1" "$2"; }
info() { printf '\033[0;34m==> %s\033[0m\n' "$1"; }
warn() { printf '\033[0;33m==> WARNING: %s\033[0m\n' "$1"; }
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

ensure_tools() {
	local tools=(rbw mas)
	local to_install=()
	for tool in "${tools[@]}"; do
		if ! brew list "$tool" >/dev/null; then
			to_install+=("$tool")
		fi
	done
	if [ "${#to_install[@]}" -eq 0 ]; then
		info "Bootstrap tools already installed"
		return
	fi
	info "Installing bootstrap tools: ${to_install[*]}..."
	brew install "${to_install[@]}"
	success "Bootstrap tools installed"
}

ensure_bitwarden() {
	if rbw unlocked >/dev/null; then
		info "Bitwarden already unlocked"
		return
	fi
	if rbw unlock >/dev/null; then
		success "Bitwarden unlocked"
		return
	fi
	local bw_email
	prompt "Bitwarden email address: " bw_email
	if [ -z "$bw_email" ]; then
		error "Email address is required"
	fi
	rbw config set email "$bw_email"
	local bw_server_url
	prompt "Bitwarden server URL (leave blank for default): " bw_server_url
	if [ -n "$bw_server_url" ]; then
		info "Configuring Bitwarden server..."
		rbw config set base_url "$bw_server_url"
	fi
	info "Logging in to Bitwarden..."
	rbw login
	rbw unlock
	success "Bitwarden authenticated and unlocked"
}

ensure_appstore() {
	local state_file="/tmp/.bootstrap-appstore-signedin"
	if [[ -f $state_file ]]; then
		info "App Store sign-in already confirmed"
		return
	fi
	local signed_in
	prompt "Are you signed in to the App Store? [Y/n] " signed_in
	if [[ ! $signed_in =~ ^[Nn]$ ]]; then
		info "App Store already signed in"
		touch "$state_file"
		return
	fi
	info "Opening App Store for sign-in..."
	mas open
	prompt "Press Enter once you have signed in to the App Store..." _
	touch "$state_file"
	success "App Store sign-in confirmed"
}

ensure_homebrew
ensure_tools
ensure_bitwarden
ensure_appstore
