<#
.SYNOPSIS
    Installs development tools on Windows via winget.
.DESCRIPTION
    Cloud/Kubernetes CLIs, language toolchains and command-line utilities. Already installed
    packages are upgraded by winget. Safe to run repeatedly.
#>

$ErrorActionPreference = 'Stop'

$WingetPackages = @(
    # Azure & Kubernetes
    'Microsoft.AzureCLI'
    'Microsoft.Azd'
    'Microsoft.Bicep'
    'Kubernetes.kubectl'
    'Microsoft.Azure.Kubelogin'
    'Helm.Helm'
    'Derailed.k9s'
    'ahmetb.kubectx'
    'ahmetb.kubens'
    # Source control & containers
    'GitHub.cli'
    'Docker.DockerCLI'
    'Atlassian.AtlassianCLI'
    # Languages & runtimes
    'Microsoft.DotNet.SDK.10'
    'Microsoft.DotNet.SDK.9'
    'Microsoft.Aspire'
    'OpenJS.NodeJS.LTS'
    'astral-sh.uv'
    'Rustlang.Rustup'
    # Utilities
    'FiloSottile.mkcert'
    'SQLite.SQLite'
    'jqlang.jq'
    'MikeFarah.yq'
    'junegunn.fzf'
    'sharkdp.fd'
    'sharkdp.bat'
)

$DotnetTools = @(
    'dotnet-ef'
    'dotnet-coverage'
    'Microsoft.OpenApi.Hidi'
)

$failed = @()

Write-Host 'Installing winget packages' -ForegroundColor Cyan
foreach ($id in $WingetPackages) {
    Write-Host "  $id" -ForegroundColor Green
    winget install --id $id --exact --silent --accept-package-agreements --accept-source-agreements
    # -1978335189: no upgrade available, -1978335135: already installed
    if ($LASTEXITCODE -notin 0, -1978335189, -1978335135) { $failed += $id }
}

# Pick up PATH changes from the installers without restarting the shell
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')

Write-Host 'Installing .NET global tools' -ForegroundColor Cyan
foreach ($tool in $DotnetTools) {
    Write-Host "  $tool" -ForegroundColor Green
    # update installs the tool when it is missing
    dotnet tool update --global $tool
    if ($LASTEXITCODE -ne 0) { $failed += $tool }
}

if ($failed) {
    Write-Host "Failed: $($failed -join ', ')" -ForegroundColor Red
    exit 1
}
Write-Host 'Done. Open a new shell to pick up PATH changes.' -ForegroundColor Cyan
