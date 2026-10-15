#!/usr/bin/env bash
# Installs development tools on Linux (Debian/Ubuntu).
#
# Cloud/Kubernetes CLIs, language toolchains and command-line utilities. Tools that are
# already on PATH are skipped; apt packages are installed or upgraded. Safe to run repeatedly.
set -euo pipefail

BIN=/usr/local/bin
ARCH=$(dpkg --print-architecture) # amd64 or arm64
case "$ARCH" in
  amd64) ALT_ARCH=x64 ;;
  arm64) ALT_ARCH=arm64 ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

have() { command -v "$1" >/dev/null; }
step() { echo; echo "== $1"; }

# Downloads a single binary to $BIN.
install_binary() {
  local name=$1 url=$2
  curl -fsSL "$url" -o "/tmp/$name"
  sudo install -m 0755 "/tmp/$name" "$BIN/$name"
  rm "/tmp/$name"
}

step "apt packages"
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg unzip \
  jq fzf fd-find bat sqlite3 mkcert libnss3-tools kubectx
# Debian ships fd and bat as fdfind and batcat
mkdir -p ~/.local/bin
have fd || ln -sf "$(command -v fdfind)" ~/.local/bin/fd
have bat || ln -sf "$(command -v batcat)" ~/.local/bin/bat

step "GitHub CLI"
if ! have gh; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null
  echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update && sudo apt-get install -y gh
fi

step "Azure CLI"
have az || curl -fsSL https://aka.ms/InstallAzureCLIDeb | sudo bash

step "Azure Developer CLI"
have azd || curl -fsSL https://aka.ms/install-azd.sh | bash

step "Bicep"
have bicep || install_binary bicep "https://github.com/Azure/bicep/releases/latest/download/bicep-linux-$ALT_ARCH"

step "kubectl"
have kubectl || install_binary kubectl "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/$ARCH/kubectl"

step "kubelogin"
if ! have kubelogin; then
  curl -fsSL "https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-$ARCH.zip" -o /tmp/kubelogin.zip
  unzip -qo /tmp/kubelogin.zip -d /tmp/kubelogin
  sudo install -m 0755 "/tmp/kubelogin/bin/linux_$ARCH/kubelogin" "$BIN/kubelogin"
  rm -rf /tmp/kubelogin /tmp/kubelogin.zip
fi

step "Helm"
have helm || curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash

step "k9s"
if ! have k9s; then
  curl -fsSL "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_$ARCH.tar.gz" | tar -xz -C /tmp k9s
  sudo install -m 0755 /tmp/k9s "$BIN/k9s"
  rm /tmp/k9s
fi

step "yq"
# apt's yq is a different (Python) tool; use mikefarah/yq
have yq || install_binary yq "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_$ARCH"

step "Atlassian CLI"
have acli || install_binary acli "https://acli.atlassian.com/linux/latest/acli_linux_$ARCH/acli"

step "Docker Engine"
if ! have docker; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$USER"
fi

step ".NET SDK 10 and 9"
curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
bash /tmp/dotnet-install.sh --channel 10.0 --install-dir ~/.dotnet
bash /tmp/dotnet-install.sh --channel 9.0 --install-dir ~/.dotnet
rm /tmp/dotnet-install.sh
export PATH="$HOME/.dotnet:$HOME/.dotnet/tools:$PATH"

step ".NET global tools"
for tool in dotnet-ef dotnet-coverage Microsoft.OpenApi.Hidi; do
  # update installs the tool when it is missing
  dotnet tool update --global "$tool"
done

step "Aspire CLI"
have aspire || curl -fsSL https://aspire.dev/install.sh | bash

step "Node.js LTS"
if ! have node; then
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

step "uv"
have uv || curl -LsSf https://astral.sh/uv/install.sh | sh

step "Rust"
have rustup || curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path

echo
echo "Done. Open a new shell to pick up PATH changes (and the docker group)."
