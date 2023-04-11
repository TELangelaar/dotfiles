# Create symlinks 
	# Neovim
cmd /c mklink /D $HOME\AppData\Local\nvim $PWD\.config\nvim\
	# Terminal settings
cmd /c mklink $HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json $PWD\WindowsTerminal\settings.json
	# Powershell settings
$ProfilePath = $HOME\Documents\WindowsPowerShell
if (Test-Path $ProfilePath) {
	if (Test-Path -Path $PROFILE -PathType -leaf) {
		del $PROFILE
	}
	cmd /c mklink $PROFILE $PWD\PowerShell\Microsoft.PowerShell_profile.ps1
}

# Install choco so we can install llvm (needed for treesitter)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
refreshenv
choco install llvm

# Install Neovim
winget install Neovim.Neovim

