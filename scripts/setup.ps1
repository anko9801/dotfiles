#Requires -RunAsAdministrator
# Windows Setup Script
# irm https://raw.githubusercontent.com/anko9801/dotfiles/master/scripts/setup.ps1 | iex

$ErrorActionPreference = "Stop"
$dotfilesPath = "$env:USERPROFILE\dotfiles"
$repo = "https://github.com/anko9801/dotfiles.git"

Write-Host @"

  ╔═══════════════════════════════════════╗
  ║         Dotfiles Setup Script         ║
  ╚═══════════════════════════════════════╝

"@ -ForegroundColor Cyan

# =============================================================================
# 1. Install winget if not available
# =============================================================================
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "[1/5] Installing winget..." -ForegroundColor Yellow
    $progressPreference = 'silentlyContinue'
    Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile winget.msixbundle
    Add-AppxPackage winget.msixbundle
    Remove-Item winget.msixbundle
} else {
    Write-Host "[1/5] winget already installed" -ForegroundColor Green
}

# =============================================================================
# 2. Clone or update dotfiles
# =============================================================================
Write-Host "[2/5] Setting up dotfiles..." -ForegroundColor Yellow
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Git first..." -ForegroundColor Yellow
    winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
    $env:PATH += ";C:\Program Files\Git\cmd"
}

if (-not (Test-Path $dotfilesPath)) {
    git clone $repo $dotfilesPath
    Write-Host "  Cloned to $dotfilesPath" -ForegroundColor Green
} else {
    Push-Location $dotfilesPath
    git pull --rebase
    Pop-Location
    Write-Host "  Updated" -ForegroundColor Green
}

# =============================================================================
# 3. Install winget packages
# =============================================================================
Write-Host "[3/5] Installing packages..." -ForegroundColor Yellow
$packagesJson = "$dotfilesPath\windows\winget-packages.json"
if (Test-Path $packagesJson) {
    winget import -i $packagesJson --accept-package-agreements --accept-source-agreements --ignore-unavailable
} else {
    Write-Host "  WARNING: $packagesJson not found" -ForegroundColor Yellow
}

# =============================================================================
# 4. Enable WSL
# =============================================================================
Write-Host "[4/5] Configuring WSL..." -ForegroundColor Yellow
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
$vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
$needsRestart = $false

if ($wslFeature.State -ne "Enabled" -or $vmFeature.State -ne "Enabled") {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction SilentlyContinue
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction SilentlyContinue
    Write-Host "  WSL enabled (restart required)" -ForegroundColor Yellow
    $needsRestart = $true
} else {
    wsl --set-default-version 2 2>$null
    Write-Host "  WSL configured" -ForegroundColor Green
}

# =============================================================================
# 5. Setup PowerShell profile
# =============================================================================
Write-Host "[5/5] Setting up PowerShell profile..." -ForegroundColor Yellow

$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$profileContent = @'
# PowerShell Profile - managed by dotfiles

# Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Aliases
Set-Alias -Name g -Value git
Set-Alias -Name c -Value code
Set-Alias -Name which -Value Get-Command

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ../.. }

# WSL
function w { wsl }

# Update everything
function Update-Dotfiles {
    Write-Host "Updating..." -ForegroundColor Cyan
    Push-Location $env:USERPROFILE\dotfiles
    git pull --rebase
    winget import -i windows\winget-packages.json --accept-package-agreements --accept-source-agreements --ignore-unavailable
    Pop-Location
    Write-Host "Done!" -ForegroundColor Green
}

function Update-All {
    winget upgrade --all --accept-package-agreements --accept-source-agreements
}
'@

Set-Content -Path $PROFILE -Value $profileContent -Encoding UTF8

# =============================================================================
# Git config
# =============================================================================
git config --global core.autocrlf input
git config --global init.defaultBranch main
git config --global pull.rebase true

# =============================================================================
# Done
# =============================================================================
Write-Host @"

  ╔═══════════════════════════════════════╗
  ║            Setup Complete!            ║
  ╚═══════════════════════════════════════╝

  Commands:
    Update-Dotfiles  - Sync dotfiles & packages
    Update-All       - Upgrade all packages
    w                - Start WSL

"@ -ForegroundColor Cyan

if ($needsRestart) {
    Write-Host "  Restart required for WSL!" -ForegroundColor Yellow
}
