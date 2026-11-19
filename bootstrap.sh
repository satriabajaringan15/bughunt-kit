#!/usr/bin/env bash
# bootstrap.sh — install toolchain bug bounty (idempotent, Linux amd64)
set -euo pipefail
GO_VERSION="${GO_VERSION:-1.22.10}"

SUDO=""
if [ "$(id -u)" -ne 0 ]; then SUDO="sudo"; fi

echo "[1/5] paket sistem"
$SUDO apt-get update -qq
DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y -qq git curl jq nmap sqlmap python3-pip python3-venv

echo "[2/5] Go ${GO_VERSION}"
if ! /usr/local/go/bin/go version >/dev/null 2>&1; then
  curl -sSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tgz
  $SUDO tar -C /usr/local -xzf /tmp/go.tgz
fi
grep -q 'go/bin' "$HOME/.bashrc" 2>/dev/null || \
  echo 'export PATH=/usr/local/go/bin:$HOME/go/bin:$HOME/.local/bin:$PATH' >> "$HOME/.bashrc"
export PATH=/usr/local/go/bin:$HOME/go/bin:$HOME/.local/bin:$PATH
export GOFLAGS=-mod=mod

echo "[3/5] tool Go (recon + fuzz)"
for pkg in \
  github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest \
  github.com/projectdiscovery/httpx/cmd/httpx@latest \
  github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest \
  github.com/projectdiscovery/katana/cmd/katana@latest \
  github.com/lc/gau@latest \
  github.com/ffuf/ffuf/v2@latest \
  github.com/hahwul/dalfox/v2@latest \
  github.com/OJ/gobuster/v3@latest ; do
  echo "  -> $pkg"
  go install "$pkg"
done

echo "[4/5] tool Python"
python3 -m pip install --break-system-packages -q uro
python3 -m pip install --break-system-packages -q "git+https://github.com/devanshbatham/ParamSpider.git" || \
  echo "  ParamSpider gagal (opsional)"

echo "[5/5] nuclei templates"
"$HOME/go/bin/nuclei" -ut -silent || echo "  jalankan 'nuclei -ut' manual"

echo "DONE. Buka shell baru atau 'source ~/.bashrc'."
