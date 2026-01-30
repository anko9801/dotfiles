# Sync winget packages with dotfiles
# Run: powershell -ExecutionPolicy Bypass -File sync.ps1

$dotfilesPath = "$env:USERPROFILE\dotfiles"
$packagesJson = "$dotfilesPath\windows\winget-packages.json"

Write-Host "Syncing winget packages..." -ForegroundColor Cyan

# Pull latest dotfiles
Push-Location $dotfilesPath
git pull --rebase
Pop-Location

# Import packages
if (Test-Path $packagesJson) {
    winget import -i $packagesJson --accept-package-agreements --accept-source-agreements --ignore-unavailable
    Write-Host "Done!" -ForegroundColor Green
} else {
    Write-Host "Package file not found: $packagesJson" -ForegroundColor Red
    exit 1
}
