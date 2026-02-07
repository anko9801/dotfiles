# Git Configuration for Windows
# Uses shared config (SSoT) from shared/git/

$ErrorActionPreference = "Stop"

$dotfiles = Split-Path $PSScriptRoot
$sharedConfig = "$dotfiles\home\tools\git\config"
$sharedIgnore = "$dotfiles\home\tools\git\ignore"

Write-Host "Configuring Git..." -ForegroundColor Cyan

# Include shared config (SSoT)
git config --global include.path $sharedConfig
Write-Host "  Included shared config: $sharedConfig" -ForegroundColor Gray

# Global gitignore
git config --global core.excludesFile $sharedIgnore
Write-Host "  Set global gitignore: $sharedIgnore" -ForegroundColor Gray

# === Windows-specific settings ===
git config --global core.editor "code --wait"
git config --global credential.helper manager

# Delta (if installed)
if (Get-Command delta -ErrorAction SilentlyContinue) {
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.line-numbers true
    git config --global delta.side-by-side true
    git config --global delta.syntax-theme TwoDark
    git config --global delta.hyperlinks true
    Write-Host "  Delta configured" -ForegroundColor Gray
} else {
    Write-Host "  Delta not installed (optional: winget install dandavison.delta)" -ForegroundColor Yellow
}

Write-Host "Git configured" -ForegroundColor Green
