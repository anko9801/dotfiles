# Windows Setup Script
# Run as Administrator: .\setup.ps1
# Or called from ./setup with -StartStep 3

param(
    [int]$StartStep = 1
)

$ErrorActionPreference = "Stop"
$dotfiles = Split-Path (Split-Path $PSScriptRoot)
$total = 8

function Step {
    param([int]$n, [string]$msg, [string]$color = "Yellow")
    Write-Host "[$n/$total] $msg" -ForegroundColor $color
}

# Only show banner when running standalone
if ($StartStep -eq 1) {
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

    Write-Host "[INFO] Dotfiles: $dotfiles`n" -ForegroundColor Blue

    # [1/8] winget
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Step 1 "Installing winget..."
        Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile winget.msixbundle
        Add-AppxPackage winget.msixbundle
        Remove-Item winget.msixbundle
    } else {
        Step 1 "winget OK" "Green"
    }

    # [2/8] Git + pull
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements
        $env:PATH += ";C:\Program Files\Git\cmd"
    }

    Step 2 "Updating dotfiles..."
    Push-Location $dotfiles; git pull --rebase; Pop-Location
    Write-Host "  Updated" -ForegroundColor Green
}

# [3/8] Packages
Step 3 "Installing packages..."
$json = "$PSScriptRoot\winget-packages.json"
if (Test-Path $json) {
    winget import -i $json --accept-package-agreements --accept-source-agreements --ignore-unavailable
    Write-Host "  Packages installed" -ForegroundColor Green
} else {
    Write-Host "  winget-packages.json not found, skipping" -ForegroundColor Yellow
}

# [4/8] PowerShell modules
Step 4 "PowerShell modules..."
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
    Install-Module -Name BurntToast -Force -Scope CurrentUser
    Write-Host "  BurntToast installed" -ForegroundColor Green
} else {
    Write-Host "  BurntToast OK" -ForegroundColor Green
}

# [5/8] Git config
Step 5 "Git config..."
& "$PSScriptRoot\git-config.ps1"

# [6/8] Windows Terminal
Step 6 "Windows Terminal..."
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$wtSource = "$PSScriptRoot\windows-terminal.json"
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

# [7/8] VS Code settings
Step 7 "VS Code settings..."
& "$PSScriptRoot\sync-vscode.ps1"

# [8/8] Done
Step 8 "Complete!" "Green"
Write-Host "`n  Restart Windows Terminal to apply changes." -ForegroundColor Cyan
