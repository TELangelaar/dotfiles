# Shared definitions for install.ps1 and remove.ps1 (Windows).

$Repo = Split-Path -Parent $PSScriptRoot
$Documents = [Environment]::GetFolderPath('MyDocuments')
$BackupSuffix = '.dotfiles-bak'

# Repo path -> target path. Each target becomes a symlink into the repo.
$Links = @(
    @{ Source = 'powershell\Microsoft.PowerShell_profile.ps1'; Target = "$Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" }
    @{ Source = 'powershell\Microsoft.PowerShell_profile.ps1'; Target = "$Documents\PowerShell\Microsoft.PowerShell_profile.ps1" }
    @{ Source = 'windows-terminal\settings.json'; Target = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" }
    @{ Source = 'oh-my-posh\theme.omp.json'; Target = "$HOME\.config\oh-my-posh\theme.omp.json" }
    @{ Source = 'nvim'; Target = "$env:LOCALAPPDATA\nvim" }
    @{ Source = 'git\.gitconfig'; Target = "$HOME\.gitconfig" }
    @{ Source = 'git\ignore'; Target = "$HOME\.config\git\ignore" }
    @{ Source = 'git\windows.gitconfig'; Target = "$HOME\.config\git\os.gitconfig" }
    @{ Source = 'claude\statusline-command.ps1'; Target = "$HOME\.claude\statusline-command.ps1" }
)
foreach ($skill in Get-ChildItem "$Repo\claude\skills" -Directory) {
    $Links += @{ Source = "claude\skills\$($skill.Name)"; Target = "$HOME\.claude\skills\$($skill.Name)" }
}

# Example -> machine-specific file. Copied once, never overwritten, never committed.
$LocalFiles = @(
    @{ Source = 'powershell\profile.local.example.ps1'; Target = "$HOME\.config\powershell\profile.local.ps1" }
    @{ Source = 'git\gitconfig.local.example'; Target = "$HOME\.gitconfig.local" }
    @{ Source = 'claude\settings.local.example.json'; Target = "$HOME\.config\claude\settings.local.json" }
)

# Claude Code rewrites its settings.json (which breaks symlinks), so it is generated instead:
# claude\settings.json, overlaid with claude\settings.windows.json and the local settings.
$ClaudeSettings = "$HOME\.claude\settings.json"
$ClaudeLayers = @("$Repo\claude\settings.json", "$Repo\claude\settings.windows.json", "$HOME\.config\claude\settings.local.json")

function Get-LinkTarget([string] $Path) {
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($item -and $item.LinkType -eq 'SymbolicLink') { return @($item.Target)[0] }
    return $null
}

function Test-PointsIntoRepo([string] $Path) {
    $target = Get-LinkTarget $Path
    return $target -and $target.StartsWith($Repo, [StringComparison]::OrdinalIgnoreCase)
}

# Removes a file, or a directory link without touching what it points to.
function Remove-Entry([string] $Path) {
    (Get-Item -LiteralPath $Path -Force).Delete()
}

function Merge-Json($Base, $Overlay) {
    foreach ($prop in $Overlay.PSObject.Properties) {
        $existing = $Base.PSObject.Properties[$prop.Name]
        if ($existing -and $existing.Value -is [PSCustomObject] -and $prop.Value -is [PSCustomObject]) {
            Merge-Json $existing.Value $prop.Value | Out-Null
        } else {
            $Base | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value -Force
        }
    }
    return $Base
}

function Get-ClaudeSettings {
    $merged = [PSCustomObject]@{}
    foreach ($layer in $ClaudeLayers) {
        if (Test-Path $layer) {
            $merged = Merge-Json $merged (Get-Content $layer -Raw | ConvertFrom-Json)
        }
    }
    $json = $merged | ConvertTo-Json -Depth 50
    return $json.Replace('{{HOME}}', $HOME.Replace('\', '/'))
}
