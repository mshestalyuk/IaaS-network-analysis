#!/usr/bin/env bash
# ===========================================================================
# Etap 2 — DNS traffic
# DNS queries to the default VPC resolver and to an external resolver.
# Maps to: "Ruch DNS - zapytania do zewnetrznych resolverow"
#
# NOTE: queries to the default VPC resolver are NOT recorded by VPC Flow Logs
# (AWS excludes traffic to the Amazon-provided DNS server). Queries sent
# explicitly to 8.8.8.8 DO appear in Flow Logs. Both appear in a pcap taken
# on the bastion.
# ===========================================================================
set -uo pipefail
cd "$(dirname "$0")"
source ./config.sh

echo "=== [DNS] traffic generation ==="

DOMAINS="google.com amazon.com github.com wikipedia.org cloudflare.com pk.edu.pl"

echo "[*] A-record lookups via default VPC resolver"
for d in $DOMAINS; do
  ip=$(dig +short A "$d" 2>/dev/null | head -1)
  echo "    $d  ->  ${ip:-no answer}"
done

echo
echo "[*] A-record lookups via external resolver (8.8.8.8)"
for d in $DOMAINS; do
  ip=$(dig @8.8.8.8 +short A "$d" 2>/dev/null | head -1)
  echo "    $d @8.8.8.8  ->  ${ip:-no answer}"
done

echo
echo "[*] Other record types"
dig +short MX   google.com     2>/dev/null | head -2 | sed 's/^/    MX   /'
dig +short TXT  cloudflare.com  2>/dev/null | head -1 | sed 's/^/    TXT  /'
dig +short AAAA google.com      2>/dev/null | head -1 | sed 's/^/    AAAA /'

echo "=== [DNS] done ==="