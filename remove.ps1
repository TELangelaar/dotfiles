<#
.SYNOPSIS
    Removes the dotfiles installed by install.ps1.
.DESCRIPTION
    Deletes every symlink that points into this repo and the generated ~/.claude/settings.json,
    then restores the <name>.dotfiles-bak backups made by install.ps1, if there are any.
    Machine-specific files (profile.local.ps1, .gitconfig.local, settings.local.json) are kept
    unless -IncludeLocal is passed.
.PARAMETER IncludeLocal
    Also delete the machine-specific files.
#>
param(
    [switch] $IncludeLocal
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\scripts\dotfiles.ps1"

function Restore-Backup([string] $Path) {
    $backup = "$Path$BackupSuffix"
    if (Test-Path -LiteralPath $backup) {
        Move-Item -LiteralPath $backup -Destination $Path
        Write-Host "  restored $Path" -ForegroundColor Yellow
    }
}

Write-Host 'Removing links' -ForegroundColor Cyan
foreach ($link in $Links) {
    if (Test-PointsIntoRepo $link.Target) {
        Remove-Entry $link.Target
        Write-Host "  removed  $($link.Target)" -ForegroundColor Green
        Restore-Backup $link.Target
    } elseif (Test-Path -LiteralPath $link.Target) {
        Write-Host "  skipped  $($link.Target) (not a link into this repo)"
    }
}

Write-Host 'Claude Code settings' -ForegroundColor Cyan
if (Test-Path -LiteralPath $ClaudeSettings) {
    if ((Get-Content -LiteralPath $ClaudeSettings -Raw).Trim() -eq (Get-ClaudeSettings).Trim()) {
        Remove-Item -LiteralPath $ClaudeSettings
        Write-Host "  removed  $ClaudeSettings" -ForegroundColor Green
    } else {
        # Changed since install (e.g. by /config); keep a copy instead of losing those changes.
        $old = "$ClaudeSettings.dotfiles-old"
        Move-Item -LiteralPath $ClaudeSettings -Destination $old -Force
        Write-Host "  moved    $ClaudeSettings -> $old (it was changed after install)" -ForegroundColor Yellow
    }
    Restore-Backup $ClaudeSettings
}

if ($IncludeLocal) {
    Write-Host 'Removing machine-specific files' -ForegroundColor Cyan
    foreach ($file in $LocalFiles) {
        if (Test-Path -LiteralPath $file.Target) {
            Remove-Item -LiteralPath $file.Target
            Write-Host "  removed  $($file.Target)" -ForegroundColor Green
        }
    }
} else {
    Write-Host 'Kept machine-specific files (pass -IncludeLocal to delete them):' -ForegroundColor Cyan
    $LocalFiles | Where-Object { Test-Path -LiteralPath $_.Target } | ForEach-Object { Write-Host "  $($_.Target)" }
}

Write-Host 'Done.' -ForegroundColor Cyan
