#!/usr/bin/env bash
# 1Password CLI plugin initialization for bash

# Enable alias expansion in non-interactive shells
shopt -s expand_aliases

# GitHub CLI integration
if command -v gh &>/dev/null && command -v op &>/dev/null; then
    alias gh='op plugin run -- gh'
    # Also define as function for non-interactive shells
    gh() {
        op plugin run -- gh "$@"
    }
    export -f gh
fi

# AWS CLI integration  
if command -v aws &>/dev/null && command -v op &>/dev/null; then
    alias aws='op plugin run -- aws'
    aws() {
        op plugin run -- aws "$@"
    }
    export -f aws
fi

# Google Cloud SDK integration
if command -v gcloud &>/dev/null && command -v op &>/dev/null; then
    alias gcloud='op plugin run -- gcloud'
    gcloud() {
        op plugin run -- gcloud "$@"
    }
    export -f gcloud
fi

# Azure CLI integration
if command -v az &>/dev/null && command -v op &>/dev/null; then
    alias az='op plugin run -- az'
    az() {
        op plugin run -- az "$@"
    }
    export -f az
fi

# Stripe CLI integration
if command -v stripe &>/dev/null && command -v op &>/dev/null; then
    alias stripe='op plugin run -- stripe'
    stripe() {
        op plugin run -- stripe "$@"
    }
    export -f stripe
fi