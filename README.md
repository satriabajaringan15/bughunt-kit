# bughunt-kit

Bootstrap toolchain bug bounty (recon → fuzz → report) di lingkungan Linux minimal (Ubuntu, 2 core / ~6 GB RAM).
Dipakai bareng skill `bug-bounty` di Hermes.

## Isi tool
- **Recon**: subfinder, httpx, nmap, gobuster
- **URL/param discovery**: waybackurls, katana, paramspider, uro (dedup)
- **Fuzz/scan**: nuclei (+templates), ffuf, dalfox, sqlmap

## Install
```bash
sudo bash bootstrap.sh          # root / sudo
# setelah itu:
source ~/.bashrc
nuclei -ut                      # download templates (sekali)
```

## Pipeline singkat
```bash
subfinder -d target.com -silent | httpx -silent -o live.txt
waybackurls target.com > urls.txt
katana -u https://target.com -d 3 -silent >> urls.txt
paramspider -d target.com >> urls.txt
uro -i urls.txt -o urls_clean.txt
nuclei -l live.txt -severity medium,high,critical
dalfox file urls_clean.txt
nmap -sV --top-ports 1000 target.com
```

## Aturan
- Hanya scan aset yang **in-scope** dan authorized.
- Temuan belum tervalidasi = `needs_validation`, tanpa severity.
- Finder ≠ validator: verifikasi independen sebelum lapor.

MIT.
