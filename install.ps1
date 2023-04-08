# Create symlink from gitrepo to AppData
cmd /c mklink $HOME\AppData\Local\nvim $PWD\.config\nvim\

# Install choco so we can install llvm (needed for treesitter)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
refreshenv
choco install llvm

# Install Neovim
winget install Neovim.Neovim

