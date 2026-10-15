<#
.SYNOPSIS
    Installs the dotfiles in this repo on Windows.
.DESCRIPTION
    Symlinks the configs into place, copies machine-specific templates that don't exist yet
    and generates ~/.claude/settings.json. Existing files are moved aside to <name>.dotfiles-bak.
    Safe to run repeatedly. Creating symlinks requires Developer Mode or an elevated shell.
.PARAMETER Packages
    Also install the tools these dotfiles use, via winget.
#>
param(
    [switch] $Packages
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\scripts\dotfiles.ps1"

$WingetPackages = @(
    'Git.Git'
    'Microsoft.PowerShell'
    'Microsoft.WindowsTerminal'
    'JanDeDobbeleer.OhMyPosh'
    'Neovim.Neovim'
    'LLVM.LLVM'               # C compiler for nvim-treesitter
    'BurntSushi.ripgrep.MSVC' # telescope live grep
    'astral-sh.uv'
    'OpenJS.NodeJS.LTS'       # Claude Code hooks
    'Anthropic.ClaudeCode'
)

function Move-ToBackup([string] $Path) {
    $backup = "$Path$BackupSuffix"
    if (Test-Path -LiteralPath $backup) { $backup = "$Path$BackupSuffix-$(Get-Date -Format 'yyyyMMddHHmmss')" }
    Move-Item -LiteralPath $Path -Destination $backup
    Write-Host "  backed up $Path -> $backup" -ForegroundColor Yellow
}

function Install-Link([string] $Source, [string] $Target) {
    $sourcePath = Join-Path $Repo $Source
    if ((Get-LinkTarget $Target) -eq $sourcePath) {
        Write-Host "  ok      $Target"
        return
    }
    if (Get-LinkTarget $Target) {
        Remove-Entry $Target
    } elseif (Test-Path -LiteralPath $Target) {
        Move-ToBackup $Target
    }
    New-Item -ItemType Directory -Force (Split-Path -Parent $Target) | Out-Null
    New-Item -ItemType SymbolicLink -Path $Target -Target $sourcePath | Out-Null
    Write-Host "  linked  $Target -> $sourcePath" -ForegroundColor Green
}

function Test-CanSymlink {
    $probe = Join-Path ([IO.Path]::GetTempPath()) "dotfiles-symlink-probe-$PID"
    try {
        New-Item -ItemType SymbolicLink -Path $probe -Target $PSCommandPath -ErrorAction Stop | Out-Null
        Remove-Item -LiteralPath $probe -Force
        return $true
    } catch {
        return $false
    }
}

if ($Packages) {
    Write-Host 'Installing packages' -ForegroundColor Cyan
    foreach ($id in $WingetPackages) {
        winget install --id $id --exact --silent --accept-package-agreements --accept-source-agreements
    }
}

if (-not (Test-CanSymlink)) {
    Write-Error 'Cannot create symlinks. Enable Developer Mode (Settings > System > For developers) or run this script from an elevated shell.'
}

Write-Host 'Linking dotfiles' -ForegroundColor Cyan
foreach ($link in $Links) {
    Install-Link $link.Source $link.Target
}

Write-Host 'Machine-specific files' -ForegroundColor Cyan
foreach ($file in $LocalFiles) {
    if (Test-Path -LiteralPath $file.Target) {
        Write-Host "  ok      $($file.Target)"
    } else {
        New-Item -ItemType Directory -Force (Split-Path -Parent $file.Target) | Out-Null
        Copy-Item (Join-Path $Repo $file.Source) $file.Target
        Write-Host "  created $($file.Target)" -ForegroundColor Green
    }
}

Write-Host 'Claude Code settings' -ForegroundColor Cyan
$settings = Get-ClaudeSettings
if ((Test-Path -LiteralPath $ClaudeSettings) -and (Get-Content -LiteralPath $ClaudeSettings -Raw).Trim() -eq $settings.Trim()) {
    Write-Host "  ok      $ClaudeSettings"
} else {
    if (Test-Path -LiteralPath $ClaudeSettings) { Move-ToBackup $ClaudeSettings }
    New-Item -ItemType Directory -Force (Split-Path -Parent $ClaudeSettings) | Out-Null
    [IO.File]::WriteAllText($ClaudeSettings, $settings + "`n")
    Write-Host "  wrote   $ClaudeSettings" -ForegroundColor Green
}

Write-Host 'Done.' -ForegroundColor Cyan
