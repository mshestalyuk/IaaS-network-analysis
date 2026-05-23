#!/usr/bin/env bash
# ===========================================================================
# Etap 2 — Malicious traffic simulation (port scanning)
# Simulates reconnaissance against the web and db servers.
# Maps to: "Symulacja ruchu zlosliwego - skanowanie portow (nmap),
#           proby polaczen na zamkniete porty"
#
# This is the key generator of REJECT records in VPC Flow Logs, which feed
# the Etap 4 "ruch dozwolony vs odrzucony" analysis.
# Uses TCP connect scan (-sT) so no root privileges are required.
# ===========================================================================
set -uo pipefail
cd "$(dirname "$0")"
source ./config.sh

echo "=== [PORT SCAN] malicious traffic simulation ==="
echo "[*] Reconnaissance from bastion — expect open ports 22/80/443 on web,"
echo "    everything else filtered by the security group (REJECT in Flow Logs)."
echo

echo "[*] TCP connect scan of WEB server, ports 1-1000 (this takes ~1 min)"
nmap -sT -T4 --max-retries 1 -n "${WEB_PRIVATE_IP}" -p 1-1000 2>/dev/null \
  | sed 's/^/    /'

echo
echo "[*] Targeted scan — allowed (22,80,443) vs blocked (3306,8080,21,23)"
nmap -sT -T4 --max-retries 1 -n "${WEB_PRIVATE_IP}" -p 21,22,23,80,443,3306,8080 2>/dev/null \
  | grep -E "^[0-9]+/tcp" | sed 's/^/    /'

echo
echo "[*] Scan DB server — 22 allowed from bastion, 3306 allowed only from web"
nmap -sT -T4 --max-retries 1 -n "${DB_PRIVATE_IP}" -p 22,3306 2>/dev/null \
  | grep -E "^[0-9]+/tcp" | sed 's/^/    /'

echo
echo "[*] Raw connection attempts to closed/filtered ports on web server"
for port in 23 3389 8080 9200 5432 6379; do
  if timeout 3 bash -c "echo > /dev/tcp/${WEB_PRIVATE_IP}/${port}" 2>/dev/null; then
    echo "    port ${port}  ->  OPEN"
  else
    echo "    port ${port}  ->  closed / filtered"
  fi
done

echo "=== [PORT SCAN] done ==="