# Git Configuration for Windows
# Mirrors settings from home/tools/git/*.nix

$ErrorActionPreference = "Stop"

Write-Host "Configuring Git..." -ForegroundColor Cyan

# === Core ===
git config --global core.editor "code --wait"
git config --global core.autocrlf false
git config --global core.safecrlf true
git config --global core.quotepath false
git config --global core.untrackedCache true
git config --global core.fsmonitor true

git config --global color.ui auto
git config --global column.ui auto
git config --global init.defaultBranch main

# === Diff/Merge ===
git config --global diff.algorithm histogram
git config --global diff.renames true
git config --global diff.colorMoved plain
git config --global diff.mnemonicPrefix true

git config --global merge.conflictstyle zdiff3

# === Pull/Push ===
git config --global pull.ff only
git config --global pull.rebase true

git config --global push.autoSetupRemote true
git config --global push.default current
git config --global push.followTags true

# === Fetch ===
git config --global fetch.prune true
git config --global fetch.pruneTags true
git config --global fetch.all true

git config --global submodule.recurse true

# === Rebase ===
git config --global rebase.autostash true
git config --global rebase.autosquash true
git config --global rebase.updateRefs true

git config --global rerere.enabled true
git config --global rerere.autoupdate true

# === Branch/Tag ===
git config --global branch.autosetupmerge always
git config --global branch.autosetuprebase always
git config --global branch.sort -committerdate

git config --global tag.sort version:refname

# === Misc ===
git config --global commit.verbose true
git config --global help.autocorrect prompt
git config --global status.showUntrackedFiles all
git config --global log.date iso
git config --global feature.manyFiles true

# === Advice (reduce noise) ===
git config --global advice.addIgnoredFile false
git config --global advice.statusHints false
git config --global advice.commitBeforeMerge false
git config --global advice.detachedHead false

# === Credential ===
git config --global credential.helper manager

# === Aliases ===
Write-Host "  Setting up aliases..." -ForegroundColor Gray

# Status/Log
git config --global alias.st "status -sb"
git config --global alias.lg "log --graph --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --abbrev-commit"
git config --global alias.root "rev-parse --show-toplevel"

# List
git config --global alias.branches "branch -a --sort=-authordate"
git config --global alias.stashes "stash list"
git config --global alias.remotes "remote -v"
git config --global alias.untracked "ls-files --others --exclude-standard"
git config --global alias.ignored "ls-files --ignored --exclude-standard --others"

# Branch
git config --global alias.sw "switch"
git config --global alias.current "rev-parse --abbrev-ref HEAD"

# Push/Pull
git config --global alias.ps "push"
git config --global alias.please "push --force-with-lease --force-if-includes"

# Commit
git config --global alias.unstage "restore --staged"
git config --global alias.amend "commit --amend"
git config --global alias.uncommit "reset --mixed HEAD~"

Write-Host "  Git configured" -ForegroundColor Green

# === Global Gitignore ===
Write-Host "  Setting up global gitignore..." -ForegroundColor Gray

$gitignoreDir = "$env:USERPROFILE\.config\git"
$gitignorePath = "$gitignoreDir\ignore"

if (-not (Test-Path $gitignoreDir)) {
    New-Item -ItemType Directory -Path $gitignoreDir -Force | Out-Null
}

$ignoreContent = @"
# OS
.DS_Store
Thumbs.db
Desktop.ini

# Editors
*.swp
*.swo
*~
.idea/
.vscode/
*.sublime-*
.*.un~

# Build artifacts
node_modules/
__pycache__/
*.pyc
*.pyo
.pytest_cache/
target/
dist/
build/
*.egg-info/

# Environment
.env
.env.local
.env.*.local
.envrc
.direnv/

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Misc
*.bak
*.tmp
*.temp
.cache/
.worktrees/
"@

Set-Content -Path $gitignorePath -Value $ignoreContent -Encoding UTF8
git config --global core.excludesFile $gitignorePath

Write-Host "  Global gitignore configured" -ForegroundColor Green

# === Delta (optional) ===
if (Get-Command delta -ErrorAction SilentlyContinue) {
    Write-Host "  Configuring delta..." -ForegroundColor Gray
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.line-numbers true
    git config --global delta.side-by-side true
    git config --global delta.syntax-theme TwoDark
    git config --global delta.hyperlinks true
    Write-Host "  Delta configured" -ForegroundColor Green
} else {
    Write-Host "  Delta not installed (optional: winget install dandavison.delta)" -ForegroundColor Yellow
}

Write-Host "Git configuration complete!" -ForegroundColor Green
