#!/usr/bin/env bash
# ===========================================================================
# Etap 2 — ICMP traffic
# Ping between instances and to external hosts; traceroute.
# Maps to: "Ruch ICMP - ping miedzy instancjami i do zewnetrznych hostow"
#
# Intra-VPC ping requires the ICMP ingress rule added to the security groups
# (allow ICMP from the VPC CIDR). Without it, the web/db pings will time out.
# ===========================================================================
set -uo pipefail
cd "$(dirname "$0")"
source ./config.sh

echo "=== [ICMP] traffic generation ==="

echo "[*] Ping WEB server (intra-VPC, instance-to-instance)"
ping -c 5 "${WEB_PRIVATE_IP}" 2>/dev/null | tail -3 | sed 's/^/    /' \
  || echo "    ping failed — is the ICMP security-group rule applied?"

echo
echo "[*] Ping DB server (private subnet)"
ping -c 5 "${DB_PRIVATE_IP}" 2>/dev/null | tail -3 | sed 's/^/    /' \
  || echo "    ping failed — is the ICMP security-group rule applied?"

echo
echo "[*] Ping external host (${EXTERNAL_HOST}, internet path via IGW)"
ping -c 5 "${EXTERNAL_HOST}" 2>/dev/null | tail -3 | sed 's/^/    /' \
  || echo "    external ping failed"

echo
echo "[*] traceroute to external host"
traceroute -n -m 8 "${EXTERNAL_HOST}" 2>/dev/null | head -10 | sed 's/^/    /'

echo "=== [ICMP] done ==="