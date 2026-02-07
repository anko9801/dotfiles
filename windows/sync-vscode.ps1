# Sync VS Code settings from WSL dotfiles to Windows
# Run from PowerShell: .\sync-vscode.ps1

$ErrorActionPreference = "Stop"

$wslDistro = "Ubuntu-24.04"
$dotfilesPath = "\\wsl$\$wslDistro\home\anko\dotfiles"
$vscodeUserPath = "$env:APPDATA\Code\User"

$sourceSettings = "$dotfilesPath\home\editor\vscode\settings.json"
$targetSettings = "$vscodeUserPath\settings.json"

if (-not (Test-Path $sourceSettings)) {
    Write-Error "Source settings not found: $sourceSettings"
    exit 1
}

if (-not (Test-Path $vscodeUserPath)) {
    New-Item -ItemType Directory -Path $vscodeUserPath -Force | Out-Null
}

if (Test-Path $targetSettings) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupDir = "$vscodeUserPath\backups"
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    $backup = "$backupDir\settings-$timestamp.json"
    Copy-Item $targetSettings $backup -Force
    Write-Host "Backed up existing settings to: $backup"

    # Keep only last 10 backups
    Get-ChildItem $backupDir -Filter "settings-*.json" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -Skip 10 |
        Remove-Item -Force
}

Copy-Item $sourceSettings $targetSettings -Force
Write-Host "Synced VS Code settings from WSL dotfiles"
Write-Host "Source: $sourceSettings"
Write-Host "Target: $targetSettings"
