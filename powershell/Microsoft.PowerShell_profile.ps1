if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
  oh-my-posh init pwsh --config "$($HOME)\.config\oh-my-posh\theme.omp.json" | Invoke-Expression
}

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# Functions

function co
{
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            $branchList = (git branch --format='%(refname:short)')

            if ([string]::IsNullOrWhiteSpace($wordToComplete)) {
                return $branchList;
            }

            $branchList | Select-String "$wordToComplete"
        })]
        [string] $branch
    )

    git checkout $branch;
}

function cor
{
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            $branchList = (git branch -r --format='%(refname:short)')

            if ([string]::IsNullOrWhiteSpace($wordToComplete)) {
                return $branchList;
            }

            $branchList | Select-String "$wordToComplete"
        })]
        [string] $branch
    )

    git checkout $branch.Substring(7); # $branch = origin/feature/xx, substring removes origin/ 
}

function dbl 
{
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            $branchList = (git branch --format='%(refname:short)')

            if ([string]::IsNullOrWhiteSpace($wordToComplete)) {
                return $branchList;
            }

            $branchList | Select-String "$wordToComplete"
        })]
        [string] $branch
    )

    git branch -D $branch;
}

function dbla {
    $branchList = git branch --format='%(refname:short)'

    foreach ($branch in $branchList) {
        if ($branch -notcontains 'master') {
            Write-Output $branch
            git branch -D $branch;
        }
    }
}

function runcy {
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            $e2eTestsList = Get-ChildItem -Path ".\apps\client-e2e\src\e2e\" -Recurse -Filter *.cy.ts
            
            if ([string]::IsNullOrWhiteSpace($wordToComplete)) {
                return $e2eTestsList.Name;
            }

            $e2eTestsList.Name | Select-String "$wordToComplete"
        })]
        [string] $cyTests
    )
    npx nx run client-e2e:e2e --base-url https://localhost:4200 --env.RUN_ID=1 --spec "**\*$($cyTests)"
}

function gs {
  git status
}

if (Get-Command uv -ErrorAction SilentlyContinue) {
  (& uv generate-shell-completion powershell) | Out-String | Invoke-Expression
}

# Machine-specific settings (not in the dotfiles repo)
$LocalProfile = "$($HOME)\.config\powershell\profile.local.ps1"
if (Test-Path $LocalProfile) {
  . $LocalProfile
}
