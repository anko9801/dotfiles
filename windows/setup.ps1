# Windows Setup Script
# Run as Administrator: powershell -ExecutionPolicy Bypass -File setup.ps1

$ErrorActionPreference = "Stop"
$dotfilesPath = "$env:USERPROFILE\dotfiles"

Write-Host "=== Windows Setup ===" -ForegroundColor Cyan

# Clone dotfiles if not exists
if (-not (Test-Path $dotfilesPath)) {
    Write-Host "Cloning dotfiles..." -ForegroundColor Yellow
    git clone https://github.com/anko9801/dotfiles.git $dotfilesPath
}

# Install winget packages
Write-Host "`nInstalling winget packages..." -ForegroundColor Yellow
$packagesJson = "$dotfilesPath\windows\winget-packages.json"
if (Test-Path $packagesJson) {
    winget import -i $packagesJson --accept-package-agreements --accept-source-agreements --ignore-unavailable
} else {
    Write-Host "winget-packages.json not found at $packagesJson" -ForegroundColor Red
}

# Enable WSL
Write-Host "`nEnabling WSL..." -ForegroundColor Yellow
$wslEnabled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
if ($wslEnabled.State -ne "Enabled") {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    Write-Host "WSL enabled. Please restart and run this script again." -ForegroundColor Yellow
}

# Set WSL default version
wsl --set-default-version 2

# Configure Git
Write-Host "`nConfiguring Git..." -ForegroundColor Yellow
git config --global core.autocrlf input
git config --global init.defaultBranch main

# PowerShell profile setup
Write-Host "`nSetting up PowerShell profile..." -ForegroundColor Yellow
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force
}

$profileContent = @'
# PowerShell Profile

# Aliases
Set-Alias -Name g -Value git
Set-Alias -Name c -Value code
Set-Alias -Name which -Value Get-Command

# Functions
function ll { Get-ChildItem -Force $args }
function la { Get-ChildItem -Force -Hidden $args }
function .. { Set-Location .. }
function ... { Set-Location ../.. }

# WSL shortcut
function wsl-dotfiles { wsl -e zsh -c "cd ~/dotfiles && zsh" }

# Update dotfiles and winget packages
function Update-Dotfiles {
    Push-Location $env:USERPROFILE\dotfiles
    git pull
    winget import -i windows\winget-packages.json --accept-package-agreements --accept-source-agreements --ignore-unavailable
    Pop-Location
    Write-Host "Dotfiles updated!" -ForegroundColor Green
}

# Prompt
function prompt {
    $path = (Get-Location).Path.Replace($env:USERPROFILE, "~")
    "$path> "
}
'@

Set-Content -Path $PROFILE -Value $profileContent -Encoding UTF8
Write-Host "PowerShell profile created at $PROFILE" -ForegroundColor Green

Write-Host "`n=== Setup Complete ===" -ForegroundColor Cyan
Write-Host "Run 'Update-Dotfiles' to sync packages anytime." -ForegroundColor Gray
