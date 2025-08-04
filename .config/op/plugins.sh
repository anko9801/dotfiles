#!/usr/bin/env bash
# 1Password Shell Plugins Configuration
# This file sets up 1Password plugins for various CLI tools
# Run this after installing 1Password CLI

# Check if op is available
if ! command -v op &>/dev/null; then
    echo "1Password CLI not found. Please install it first."
    exit 1
fi

# GitHub CLI
if command -v gh &>/dev/null; then
    echo "Setting up GitHub CLI plugin..."
    op plugin init gh
fi

# AWS CLI
if command -v aws &>/dev/null; then
    echo "Setting up AWS CLI plugin..."
    op plugin init aws
fi

# Google Cloud SDK
if command -v gcloud &>/dev/null; then
    echo "Setting up Google Cloud CLI plugin..."
    op plugin init gcloud
fi

# Azure CLI
if command -v az &>/dev/null; then
    echo "Setting up Azure CLI plugin..."
    op plugin init az
fi

# Stripe CLI
if command -v stripe &>/dev/null; then
    echo "Setting up Stripe CLI plugin..."
    op plugin init stripe
fi

echo "1Password plugins setup complete!"
echo "You can now remove local credentials from:"
echo "  - ~/.config/gh/hosts.yml (GitHub)"
echo "  - ~/.aws/credentials (AWS)"
echo "  - ~/.config/gcloud/ (Google Cloud)"
echo "  - etc."