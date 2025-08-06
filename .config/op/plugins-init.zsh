#!/usr/bin/env zsh
# 1Password CLI plugin initialization for zsh

# GitHub CLI integration
if command -v gh &>/dev/null && command -v op &>/dev/null; then
    alias gh='op plugin run -- gh'
fi

# AWS CLI integration  
if command -v aws &>/dev/null && command -v op &>/dev/null; then
    alias aws='op plugin run -- aws'
fi

# Google Cloud SDK integration
if command -v gcloud &>/dev/null && command -v op &>/dev/null; then
    alias gcloud='op plugin run -- gcloud'
fi

# Azure CLI integration
if command -v az &>/dev/null && command -v op &>/dev/null; then
    alias az='op plugin run -- az'
fi

# Stripe CLI integration
if command -v stripe &>/dev/null && command -v op &>/dev/null; then
    alias stripe='op plugin run -- stripe'
fi