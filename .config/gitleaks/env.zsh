#!/usr/bin/env zsh
# Gitleaks environment configuration

# Set XDG config location for gitleaks
export GITLEAKS_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/gitleaks/config.toml"

# Alias to use XDG config by default
alias gitleaks='gitleaks --config "${GITLEAKS_CONFIG}"'