# Windows Setup Script
# Run as Administrator: .\setup.ps1

$ErrorActionPreference = "Stop"
$dotfiles = Split-Path (Split-Path $PSScriptRoot)

Write-Host @"

  ╔═══════════════════════════════════════╗
  ║       Dotfiles Setup (Windows)        ║
  ╚═══════════════════════════════════════╝

"@ -ForegroundColor Cyan

# Check admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run as Administrator!" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Dotfiles: $dotfiles" -ForegroundColor Blue

# winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "[1/7] Installing winget..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile winget.msixbundle
    Add-AppxPackage winget.msixbundle
    Remove-Item winget.msixbundle
} else {
    Write-Host "[1/7] winget OK" -ForegroundColor Green
}

# Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
    $env:PATH += ";C:\Program Files\Git\cmd"
}

Write-Host "[2/7] Git pull..." -ForegroundColor Yellow
Push-Location $dotfiles; git pull --rebase; Pop-Location
Write-Host "  Updated dotfiles" -ForegroundColor Green

# Packages
Write-Host "[3/7] Packages..." -ForegroundColor Yellow
$json = "$dotfiles\system\windows\winget-packages.json"
if (Test-Path $json) {
    winget import -i $json --accept-package-agreements --accept-source-agreements --ignore-unavailable
} else {
    Write-Host "  winget-packages.json not found, skipping" -ForegroundColor Yellow
}

# PowerShell modules
Write-Host "[4/7] PowerShell modules..." -ForegroundColor Yellow
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
    Install-Module -Name BurntToast -Force -Scope CurrentUser
    Write-Host "  BurntToast installed" -ForegroundColor Green
} else {
    Write-Host "  BurntToast OK" -ForegroundColor Green
}

# Git config
Write-Host "[5/7] Git config..." -ForegroundColor Yellow
& "$PSScriptRoot\git-config.ps1"

# Windows Terminal
Write-Host "[6/7] Windows Terminal..." -ForegroundColor Yellow
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$wtSource = "$dotfiles\system\windows\windows-terminal.json"
if (Test-Path $wtSource) {
    $wtDir = Split-Path $wtSettings
    if (Test-Path $wtDir) {
        if (Test-Path $wtSettings) {
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            Copy-Item $wtSettings "$wtSettings.$timestamp.bak" -Force
            Write-Host "  Backed up existing settings" -ForegroundColor Gray
        }
        Copy-Item $wtSource $wtSettings -Force
        Write-Host "  Windows Terminal settings applied" -ForegroundColor Green
    } else {
        Write-Host "  Windows Terminal not installed, skipping" -ForegroundColor Yellow
    }
} else {
    Write-Host "  windows-terminal.json not found, skipping" -ForegroundColor Yellow
}

# VS Code settings
Write-Host "[7/7] VS Code settings..." -ForegroundColor Yellow
& "$PSScriptRoot\sync-vscode.ps1"

Write-Host "`n  Done! Restart Windows Terminal to apply changes." -ForegroundColor Cyan
