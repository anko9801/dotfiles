# Export currently installed winget packages
# Run: powershell -ExecutionPolicy Bypass -File export.ps1

$dotfilesPath = "$env:USERPROFILE\dotfiles"
$packagesJson = "$dotfilesPath\windows\winget-packages.json"

Write-Host "Exporting winget packages..." -ForegroundColor Cyan
winget export -o $packagesJson --include-versions:$false

Write-Host "Exported to: $packagesJson" -ForegroundColor Green
Write-Host "Review and commit changes to dotfiles." -ForegroundColor Gray
