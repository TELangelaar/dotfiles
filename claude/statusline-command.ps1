# Claude Code status line script
# Receives session JSON on stdin; prints a compact status string.

$ErrorActionPreference = 'SilentlyContinue'

# --- Read and parse stdin JSON ---
$raw = $null
try {
    $raw = [Console]::In.ReadToEnd() | ConvertFrom-Json
} catch { }

# --- 1. Basename of current working directory ---
$cwd = $null
if ($raw) {
    $cwd = $raw.workspace.current_dir
    if (-not $cwd) { $cwd = $raw.cwd }
}
if (-not $cwd) { $cwd = (Get-Location).Path }
$dirName = Split-Path -Leaf $cwd

# --- 2. Git branch ---
$branch = $null
try {
    # Run git in the workspace directory so it works regardless of agent cwd.
    $gitDir = if ($cwd) { $cwd } else { (Get-Location).Path }
    $branch = & git -C $gitDir rev-parse --abbrev-ref HEAD 2>$null
    if ($LASTEXITCODE -ne 0) { $branch = $null }
} catch { $branch = $null }

# --- 3. Model display name ---
$model = $null
if ($raw) { $model = $raw.model.display_name }

# --- 4. Context usage ---
$ctx = $null
if ($raw) {
    $used = $raw.context_window.used_percentage
    if ($null -ne $used) {
        $ctx = "ctx $([math]::Round($used))%"
    }
}

# --- Assemble parts ---
$parts = @()
if ($dirName)  { $parts += $dirName }
if ($branch)   { $parts += $branch }
if ($model)    { $parts += $model }
if ($ctx)      { $parts += $ctx }

Write-Host ($parts -join '  ')
